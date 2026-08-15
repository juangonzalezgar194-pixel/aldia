package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.ConfirmacionPago;
import com.aldia.aldia_backend.model.Notificacion;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.ConfirmacionPagoRepository;
import com.aldia.aldia_backend.service.NotificacionService;
import com.aldia.aldia_backend.util.PeriodoPagoUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/confirmaciones-pago")
@CrossOrigin(origins = "*")
public class ConfirmacionPagoController {

    @Autowired
    private ContratoRepository contratoRepository;

    @Autowired
    private ConfirmacionPagoRepository confirmacionPagoRepository;

    @Autowired
    private NotificacionService notificacionService;

    // El arrendatario confirma que pagó en efectivo (sin subir comprobante)
    @PostMapping("/efectivo/{contratoId}")
    public ResponseEntity<?> confirmarPagoEfectivo(@PathVariable Long contratoId) {
        Optional<Contrato> contratoOpt = contratoRepository.findById(contratoId);
        if (contratoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Contrato contrato = contratoOpt.get();

        LocalDate periodo = PeriodoPagoUtil.calcularFechaPagoMesActual(contrato.getDiaPago(), LocalDate.now());

        // 1. Guardar la confirmación
        ConfirmacionPago confirmacion = new ConfirmacionPago();
        confirmacion.setContratoId(contratoId);
        confirmacion.setPeriodoPago(periodo);
        confirmacion.setMetodo(ConfirmacionPago.MetodoConfirmacion.EFECTIVO);
        ConfirmacionPago guardada = confirmacionPagoRepository.save(confirmacion);

        // 2. Notificar al arrendador
        Notificacion notiArrendador = new Notificacion();
        notiArrendador.setContratoId(contratoId);
        notiArrendador.setUsuarioDestinoId(contrato.getArrendadorId());
        notiArrendador.setOrigen(Notificacion.OrigenNotificacion.AUTOMATICA);
        notiArrendador.setTipo(Notificacion.TipoNotificacion.CONFIRMACION_PAGO_EFECTIVO);
        notiArrendador.setCanal(Notificacion.CanalNotificacion.EMAIL);
        notiArrendador.setFechaPagoReferencia(periodo);
        notificacionService.crearYEnviar(notiArrendador);

        // 3. Confirmar al arrendatario que su confirmación quedó registrada
        Notificacion notiArrendatario = new Notificacion();
        notiArrendatario.setContratoId(contratoId);
        notiArrendatario.setUsuarioDestinoId(contrato.getArrendatarioId());
        notiArrendatario.setOrigen(Notificacion.OrigenNotificacion.AUTOMATICA);
        notiArrendatario.setTipo(Notificacion.TipoNotificacion.PAGO_REGISTRADO);
        notiArrendatario.setCanal(Notificacion.CanalNotificacion.EMAIL);
        notiArrendatario.setFechaPagoReferencia(periodo);
        notificacionService.crearYEnviar(notiArrendatario);

        return ResponseEntity.ok(guardada);
    }

    @GetMapping("/contrato/{contratoId}")
    public ResponseEntity<?> porContrato(@PathVariable Long contratoId) {
        return ResponseEntity.ok(confirmacionPagoRepository.findByContratoId(contratoId));
    }
}