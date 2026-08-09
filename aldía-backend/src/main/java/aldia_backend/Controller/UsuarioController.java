package com.aldia.aldia_backend.Controller;

import com.aldia.aldia_backend.model.Usuario;
import com.aldia.aldia_backend.repository.UsuarioRepository;
import com.aldia.aldia_backend.security.JwtUtil;
import com.aldia.aldia_backend.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Random;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EmailService emailService;
    
    @GetMapping
    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Usuario> buscarPorId(@PathVariable Long id) {
        return usuarioRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Usuario> crear(@RequestBody Usuario usuario) {
        usuario.setContrasena(passwordEncoder.encode(usuario.getContrasena()));
        return ResponseEntity.status(201).body(usuarioRepository.save(usuario));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> actualizar(@PathVariable Long id, @RequestBody Usuario datos) {
        return usuarioRepository.findById(id).map(usuario -> {
            usuario.setNombre(datos.getNombre());
            usuario.setApellido(datos.getApellido());
            usuario.setCorreo(datos.getCorreo());
            usuario.setTelefono(datos.getTelefono());
            usuario.setActivo(datos.isActivo());
            return ResponseEntity.ok(usuarioRepository.save(usuario));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (usuarioRepository.existsById(id)) {
            usuarioRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario credenciales) {
        return usuarioRepository.findByCorreo(credenciales.getCorreo())
                .filter(u -> passwordEncoder.matches(credenciales.getContrasena(), u.getContrasena()))
                .map(u -> {
                    String token = jwtUtil.generarToken(u.getCorreo(), "USER");
                    Map<String, Object> respuesta = new HashMap<>();
                    respuesta.put("token", token);
                    respuesta.put("id", u.getId());
                    respuesta.put("nombre", u.getNombre());
                    respuesta.put("correo", u.getCorreo());
                    // ANTES: respuesta.put("rol", "USER"); <- estaba fijo, por eso
                    // Flutter nunca recibía ARRENDADOR/ARRENDATARIO real.
                    respuesta.put("rol", u.getRol());
                    return ResponseEntity.ok(respuesta);
                })
                .orElse(ResponseEntity.status(401).build());
    }

    @PostMapping("/olvide-password")
    public ResponseEntity<?> olvidePassword(@RequestBody Map<String, String> body) {
        String correo = body.get("correo");

        return usuarioRepository.findByCorreo(correo)
                .map(usuario -> {
                    String codigo = String.format("%06d", new Random().nextInt(999999));
                    usuario.setCodigoRecuperacion(codigo);
                    usuario.setCodigoExpiracion(LocalDateTime.now().plusMinutes(15));
                    usuarioRepository.save(usuario);

                    emailService.enviarCodigoRecuperacion(correo, codigo);

                    Map<String, String> respuesta = new HashMap<>();
                    respuesta.put("mensaje", "Código enviado al correo");
                    return ResponseEntity.ok(respuesta);
                })
                .orElseGet(() -> ResponseEntity.status(404).body(Map.of("error", "Correo no encontrado")));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> body) {
        String correo = body.get("correo");
        String codigo = body.get("codigo");
        String nuevaContrasena = body.get("nuevaContrasena");

        return usuarioRepository.findByCorreo(correo)
                .map(usuario -> {
                    if (usuario.getCodigoRecuperacion() == null ||
                        !usuario.getCodigoRecuperacion().equals(codigo)) {
                        return ResponseEntity.status(400).body(Map.of("error", "Código incorrecto"));
                    }
                    if (usuario.getCodigoExpiracion().isBefore(LocalDateTime.now())) {
                        return ResponseEntity.status(400).body(Map.of("error", "El código ha expirado"));
                    }

                    usuario.setContrasena(passwordEncoder.encode(nuevaContrasena));
                    usuario.setCodigoRecuperacion(null);
                    usuario.setCodigoExpiracion(null);
                    usuarioRepository.save(usuario);

                    return ResponseEntity.ok(Map.of("mensaje", "Contraseña actualizada correctamente"));
                })
                .orElse(ResponseEntity.status(404).body(Map.of("error", "Correo no encontrado")));
    }
}