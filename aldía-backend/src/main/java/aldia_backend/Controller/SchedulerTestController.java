package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.scheduler.NotificacionScheduler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/scheduler")
@CrossOrigin(origins = "*")
public class SchedulerTestController {

    @Autowired
    private NotificacionScheduler notificacionScheduler;

    // SOLO PARA PRUEBAS: dispara manualmente la revisión de avisos de pago
    @PostMapping("/probar-avisos")
    public ResponseEntity<?> probarAvisos() {
        notificacionScheduler.revisarAvisosDePago();
        return ResponseEntity.ok("Job ejecutado. Revisa la tabla notificacion y tu correo.");
    }
}