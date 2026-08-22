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

import java.math.BigDecimal;
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

    public static class PagoEfectivoRequest {
        public BigDecimal valor;
        public String nombrePagador;
        public LocalDate fechaPago;
    }

    // El arrendatario reporta que pagó en efectivo (queda PENDIENTE de confirmar)
    @PostMapping("/efectivo/{contratoId}")
    public ResponseEntity<?> reportarPagoEfectivo(
            @PathVariable Long contratoId,
            @RequestBody PagoEfectivoRequest datos) {

        Optional<Contrato> contratoOpt = contratoRepository.findById(contratoId);
        if (contratoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Contrato contrato = contratoOpt.get();

        LocalDate periodo = PeriodoPagoUtil.calcularFechaPagoMesActual(contrato.getDiaPago(), LocalDate.now());

        ConfirmacionPago confirmacion = new ConfirmacionPago();
        confirmacion.setContratoId(contratoId);
        confirmacion.setPeriodoPago(periodo);
        confirmacion.setMetodo(ConfirmacionPago.MetodoConfirmacion.EFECTIVO);
        confirmacion.setEstado(ConfirmacionPago.EstadoConfirmacion.PENDIENTE);
        confirmacion.setValor(datos.valor);
        confirmacion.setNombrePagador(datos.nombrePagador);
        confirmacion.setFechaPago(datos.fechaPago);
        ConfirmacionPago guardada = confirmacionPagoRepository.save(confirmacion);

        // Notificar al arrendador que hay un pago en efectivo por revisar
        Notificacion notiArrendador = new Notificacion();
        notiArrendador.setContratoId(contratoId);
        notiArrendador.setUsuarioDestinoId(contrato.getArrendadorId());
        notiArrendador.setOrigen(Notificacion.OrigenNotificacion.AUTOMATICA);
        notiArrendador.setTipo(Notificacion.TipoNotificacion.CONFIRMACION_PAGO_EFECTIVO);
        notiArrendador.setCanal(Notificacion.CanalNotificacion.EMAIL);
        notiArrendador.setFechaPagoReferencia(periodo);
        notificacionService.crearYEnviar(notiArrendador);

        return ResponseEntity.ok(guardada);
    }

    // El arrendador confirma (aprueba) un pago en efectivo reportado
    @PutMapping("/{id}/confirmar")
    public ResponseEntity<?> confirmarPago(@PathVariable Long id) {
        Optional<ConfirmacionPago> confirmacionOpt = confirmacionPagoRepository.findById(id);
        if (confirmacionOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ConfirmacionPago confirmacion = confirmacionOpt.get();
        confirmacion.setEstado(ConfirmacionPago.EstadoConfirmacion.CONFIRMADO);
        ConfirmacionPago actualizada = confirmacionPagoRepository.save(confirmacion);

        // Avisar al arrendatario que su pago quedó confirmado
        Optional<Contrato> contratoOpt = contratoRepository.findById(confirmacion.getContratoId());
        if (contratoOpt.isPresent()) {
            Contrato contrato = contratoOpt.get();
            Notificacion notiArrendatario = new Notificacion();
            notiArrendatario.setContratoId(confirmacion.getContratoId());
            notiArrendatario.setUsuarioDestinoId(contrato.getArrendatarioId());
            notiArrendatario.setOrigen(Notificacion.OrigenNotificacion.AUTOMATICA);
            notiArrendatario.setTipo(Notificacion.TipoNotificacion.PAGO_REGISTRADO);
            notiArrendatario.setCanal(Notificacion.CanalNotificacion.EMAIL);
            notiArrendatario.setFechaPagoReferencia(confirmacion.getPeriodoPago());
            notificacionService.crearYEnviar(notiArrendatario);
        }

        return ResponseEntity.ok(actualizada);
    }

    @GetMapping("/contrato/{contratoId}")
    public ResponseEntity<?> porContrato(@PathVariable Long contratoId) {
        return ResponseEntity.ok(confirmacionPagoRepository.findByContratoId(contratoId));
    }

    // Pagos en efectivo pendientes de un contrato (para la pantalla del arrendador)
    @GetMapping("/contrato/{contratoId}/pendientes")
    public ResponseEntity<?> pendientesPorContrato(@PathVariable Long contratoId) {
        var lista = confirmacionPagoRepository.findByContratoId(contratoId).stream()
                .filter(c -> c.getMetodo() == ConfirmacionPago.MetodoConfirmacion.EFECTIVO
                        && c.getEstado() == ConfirmacionPago.EstadoConfirmacion.PENDIENTE)
                .toList();
        return ResponseEntity.ok(lista);
    }
}