package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Notificacion;
import com.aldia.aldia_backend.repository.NotificacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/notificaciones")
@CrossOrigin(origins = "*")
public class NotificacionController {

    @Autowired
    private NotificacionRepository notificacionRepository;

    @GetMapping
    public List<Notificacion> listar() {
        return notificacionRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Notificacion> buscarPorId(@PathVariable Long id) {
        return notificacionRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/usuario/{id}")
    public List<Notificacion> porUsuario(@PathVariable Long id) {
        return notificacionRepository.findByUsuarioDestinoId(id);
    }

    @GetMapping("/contrato/{id}")
    public List<Notificacion> porContrato(@PathVariable Long id) {
        return notificacionRepository.findByContratoId(id);
    }

    @GetMapping("/estado/{estado}")
    public List<Notificacion> porEstado(@PathVariable Notificacion.EstadoNotificacion estado) {
        return notificacionRepository.findByEstado(estado);
    }

    @PostMapping
    public Notificacion crear(@RequestBody Notificacion notificacion) {
        System.out.println(">>> Recibido: " + notificacion.getTipo() + " | " + notificacion.getCanal() + " | " + notificacion.getFechaProgramada());
        try {
            return notificacionRepository.save(notificacion);
        } catch (Exception e) {
            System.out.println(">>> ERROR al guardar: " + e.getMessage());
            throw e;
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Notificacion> actualizar(@PathVariable Long id, @RequestBody Notificacion datos) {
        return notificacionRepository.findById(id).map(notificacion -> {
            notificacion.setEstado(datos.getEstado());
            notificacion.setFechaEnvio(datos.getFechaEnvio());
            notificacion.setDetalleError(datos.getDetalleError());
            return ResponseEntity.ok(notificacionRepository.save(notificacion));
        }).orElse(ResponseEntity.notFound().<Notificacion>build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (notificacionRepository.existsById(id)) {
            notificacionRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}