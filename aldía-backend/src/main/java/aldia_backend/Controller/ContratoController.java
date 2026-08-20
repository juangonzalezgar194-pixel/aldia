package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.dto.CrearContratoRequest;
import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.Inmueble;
import com.aldia.aldia_backend.model.Usuario;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.InmuebleRepository;
import com.aldia.aldia_backend.repository.UsuarioRepository;
import com.aldia.aldia_backend.service.ContratoPdfService;
import com.aldia.aldia_backend.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/contratos")
@CrossOrigin(origins = "*")
public class ContratoController {

    @Autowired
    private ContratoRepository contratoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private InmuebleRepository inmuebleRepository;

    @Autowired
    private ContratoPdfService contratoPdfService;

    @Autowired
    private EmailService emailService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping
    public List<Contrato> listar() {
        return contratoRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Contrato> buscarPorId(@PathVariable Long id) {
        return contratoRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/arrendador/{id}")
    public List<Contrato> porArrendador(@PathVariable Long id) {
        return contratoRepository.findByArrendadorId(id);
    }

    @GetMapping("/arrendatario/{id}")
    public List<Contrato> porArrendatario(@PathVariable Long id) {
        return contratoRepository.findByArrendatarioId(id);
    }

    /**
     * Crea un contrato a partir de los datos crudos del arrendatario (nombre, documento,
     * correo, teléfono) en vez de requerir un arrendatarioId ya existente.
     *
     * Flujo:
     * 1. Busca si ya existe un usuario con ese numDocumento.
     * 2. Si existe -> usa ese usuario tal cual (sin tocar su contraseña).
     * 3. Si no existe -> crea el usuario con rol ARRENDATARIO, contraseña aleatoria
     *    (inutilizable hasta que la active), y le genera un código de activación
     *    igual al de "olvidé mi contraseña", enviado por correo.
     * 4. Verifica que el inmueble exista y esté disponible.
     * 5. Crea el Contrato apuntando al arrendatarioId resuelto.
     * 6. Marca el inmueble como no disponible (ya quedó arrendado).
     *
     * El envío de correo está protegido con try-catch: si Resend falla (por el límite
     * del plan gratuito sin dominio verificado, o cualquier otra razón), el contrato
     * y el usuario igual quedan creados. El código de activación queda guardado en la
     * BD para reenviarlo o entregarlo manualmente más adelante.
     */
    @PostMapping
    public ResponseEntity<?> crear(@RequestBody CrearContratoRequest request) {

        if (request.getArrendatarioNumDocumento() == null || request.getArrendatarioNumDocumento().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "El número de documento del arrendatario es obligatorio"));
        }
        if (request.getArrendatarioCorreo() == null || request.getArrendatarioCorreo().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "El correo del arrendatario es obligatorio"));
        }

        Inmueble inmueble = inmuebleRepository.findById(request.getInmuebleId())
                .orElse(null);

        if (inmueble == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "El inmueble seleccionado no existe"));
        }
        if (!inmueble.isDisponible()) {
            return ResponseEntity.status(409).body(Map.of(
                    "error", "Este inmueble ya no está disponible. Puede que otro contrato lo haya tomado mientras completabas el formulario."
            ));
        }

        Usuario arrendatario = usuarioRepository.findByNumDocumento(request.getArrendatarioNumDocumento())
                .orElse(null);

        boolean esNuevo = (arrendatario == null);
        boolean correoEnviado = false;

        if (esNuevo) {
            // Evitar choque de 'correo' unique si el documento no existe pero el correo sí
            if (usuarioRepository.existsByCorreo(request.getArrendatarioCorreo())) {
                return ResponseEntity.status(409).body(Map.of(
                        "error", "Ya existe un usuario registrado con ese correo, pero con otro número de documento. Verifica los datos."
                ));
            }

            arrendatario = new Usuario();
            arrendatario.setNombre(request.getArrendatarioNombre());
            arrendatario.setApellido(request.getArrendatarioApellido());
            arrendatario.setNumDocumento(request.getArrendatarioNumDocumento());
            arrendatario.setCorreo(request.getArrendatarioCorreo());
            arrendatario.setTelefono(request.getArrendatarioTelefono());
            arrendatario.setRol("ARRENDATARIO");
            arrendatario.setActivo(true);

            // Contraseña temporal aleatoria e inservible: nadie la conoce, el usuario
            // solo puede entrar tras activarse con el código de 6 dígitos.
            String contrasenaAleatoria = UUID.randomUUID().toString();
            arrendatario.setContrasena(passwordEncoder.encode(contrasenaAleatoria));

            // Mismo mecanismo que "olvidé mi contraseña"
            String codigo = String.format("%06d", new Random().nextInt(999999));
            arrendatario.setCodigoRecuperacion(codigo);
            arrendatario.setCodigoExpiracion(LocalDateTime.now().plusMinutes(15));

            arrendatario = usuarioRepository.save(arrendatario);

            // El envío de correo NO debe tumbar la creación del contrato.
            // Si falla (ej: límite de Resend sin dominio verificado), lo registramos
            // en consola pero seguimos adelante — el usuario ya quedó creado y el
            // contrato se genera igual; el código de activación queda guardado en
            // la BD para reenviarlo o dárselo manualmente si hace falta.
            try {
                emailService.enviarCodigoActivacion(
                        arrendatario.getCorreo(),
                        arrendatario.getNombre(),
                        codigo
                );
                correoEnviado = true;
            } catch (Exception e) {
                System.err.println("No se pudo enviar el correo de activación a "
                        + arrendatario.getCorreo() + ": " + e.getMessage());
            }
        }

        Contrato contrato = new Contrato();
        contrato.setInmuebleId(request.getInmuebleId());
        contrato.setArrendadorId(request.getArrendadorId());
        contrato.setArrendatarioId(arrendatario.getId());
        contrato.setValorMensual(request.getValorMensual());
        contrato.setDiaPago(request.getDiaPago());
        contrato.setFechaInicio(request.getFechaInicio());
        contrato.setFechaFin(request.getFechaFin());
        contrato.setObservaciones(request.getObservaciones());

        Contrato contratoGuardado = contratoRepository.save(contrato);

        // El inmueble ya quedó arrendado: lo sacamos de la lista de disponibles.
        inmueble.setDisponible(false);
        inmuebleRepository.save(inmueble);

        return ResponseEntity.status(201).body(Map.of(
                "contrato", contratoGuardado,
                "arrendatarioNuevo", esNuevo,
                "arrendatarioId", arrendatario.getId(),
                "correoActivacionEnviado", correoEnviado
        ));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Contrato> actualizar(@PathVariable Long id, @RequestBody Contrato datos) {
        return contratoRepository.findById(id).map(contrato -> {
            contrato.setValorMensual(datos.getValorMensual());
            contrato.setDiaPago(datos.getDiaPago());
            contrato.setFechaFin(datos.getFechaFin());
            contrato.setEstado(datos.getEstado());
            contrato.setObservaciones(datos.getObservaciones());
            return ResponseEntity.ok(contratoRepository.save(contrato));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (contratoRepository.existsById(id)) {
            contratoRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<byte[]> generarPdf(@PathVariable Long id) {
        if (!contratoRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        try {
            byte[] pdfBytes = contratoPdfService.generarPdf(id);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "contrato_" + id + ".pdf");
            headers.setContentLength(pdfBytes.length);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfBytes);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}