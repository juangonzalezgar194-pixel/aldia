package com.aldia.aldia_backend.scheduler;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.Notificacion;
import com.aldia.aldia_backend.repository.ConfirmacionPagoRepository;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.NotificacionRepository;
import com.aldia.aldia_backend.service.NotificacionService;
import com.aldia.aldia_backend.util.PeriodoPagoUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Component
public class NotificacionScheduler {

    @Autowired
    private ContratoRepository contratoRepository;

    @Autowired
    private ConfirmacionPagoRepository confirmacionPagoRepository;

    @Autowired
    private NotificacionRepository notificacionRepository;

    @Autowired
    private NotificacionService notificacionService;

    // Corre todos los días a las 8:00 a.m. hora Colombia (America/Bogota)
    @Scheduled(cron = "0 0 8 * * *", zone = "America/Bogota")
    public void revisarAvisosDePago() {
        LocalDate hoy = LocalDate.now();
        System.out.println("[SCHEDULER] Ejecutando revisarAvisosDePago - " + hoy);

        List<Contrato> contratosActivos = contratoRepository.findByEstado(Contrato.EstadoContrato.ACTIVO);
        System.out.println("[SCHEDULER] Contratos activos encontrados: " + contratosActivos.size());

        int avisosGenerados = 0;
        for (Contrato contrato : contratosActivos) {
            boolean generado = procesarContrato(contrato, hoy);
            if (generado) {
                avisosGenerados++;
            }
        }

        System.out.println("[SCHEDULER] Avisos generados en esta ejecución: " + avisosGenerados);
    }

    private boolean procesarContrato(Contrato contrato, LocalDate hoy) {
        LocalDate fechaPago = PeriodoPagoUtil.calcularFechaPagoMesActual(contrato.getDiaPago(), hoy);

        // Positivo = el pago aún no llega, 0 = es hoy, negativo = ya pasó
        long diasDiferencia = ChronoUnit.DAYS.between(hoy, fechaPago);

        Notificacion.TipoNotificacion tipo = null;
        if (diasDiferencia == 3) {
            tipo = Notificacion.TipoNotificacion.RECORDATORIO_3_DIAS;
        } else if (diasDiferencia == 1) {
            tipo = Notificacion.TipoNotificacion.RECORDATORIO_1_DIA;
        } else if (diasDiferencia == 0) {
            tipo = Notificacion.TipoNotificacion.VENCIMIENTO;
        } else if (diasDiferencia == -1) {
            tipo = Notificacion.TipoNotificacion.MORA;
        }

        if (tipo == null) {
            return false; // hoy no toca ningún aviso para este contrato
        }

        // Si ya hay un pago confirmado (efectivo o comprobante) para este periodo, no molestar
        boolean yaPago = confirmacionPagoRepository.existsByContratoIdAndPeriodoPago(contrato.getId(), fechaPago);
        if (yaPago) {
            System.out.println("[SCHEDULER] Contrato " + contrato.getId() + " ya tiene pago confirmado para " + fechaPago + ", se omite.");
            return false;
        }

        // Evitar mandar el mismo aviso dos veces en el mismo periodo
        boolean yaEnviado = notificacionRepository.existsByContratoIdAndTipoAndFechaPagoReferencia(
                contrato.getId(), tipo, fechaPago);
        if (yaEnviado) {
            System.out.println("[SCHEDULER] Contrato " + contrato.getId() + " ya tiene aviso " + tipo + " enviado para " + fechaPago + ", se omite.");
            return false;
        }

        Notificacion noti = new Notificacion();
        noti.setContratoId(contrato.getId());
        noti.setUsuarioDestinoId(contrato.getArrendatarioId());
        noti.setOrigen(Notificacion.OrigenNotificacion.AUTOMATICA);
        noti.setTipo(tipo);
        noti.setCanal(Notificacion.CanalNotificacion.EMAIL);
        noti.setFechaPagoReferencia(fechaPago);

        notificacionService.crearYEnviar(noti);
        System.out.println("[SCHEDULER] Aviso " + tipo + " generado para contrato " + contrato.getId() + " (periodo " + fechaPago + ")");

        return true;
    }
}