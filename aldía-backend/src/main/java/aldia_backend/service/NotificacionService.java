package com.aldia.aldia_backend.service;

import com.aldia.aldia_backend.model.Notificacion;
import com.aldia.aldia_backend.model.Usuario;
import com.aldia.aldia_backend.repository.NotificacionRepository;
import com.aldia.aldia_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class NotificacionService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private EmailService emailService;

    @Autowired
    private NotificacionRepository notificacionRepository;

    // Arma el asunto y cuerpo del correo según el tipo de notificación
    private String[] construirMensaje(Notificacion notificacion) {
        String asunto;
        String cuerpoBase;

        switch (notificacion.getTipo()) {
            case RECORDATORIO_3_DIAS:
                asunto = "AlDía - Recordatorio: pago próximo en 3 días";
                cuerpoBase = "Te recordamos que tu pago vence en 3 días.";
                break;
            case RECORDATORIO_1_DIA:
                asunto = "AlDía - Recordatorio: pago próximo mañana";
                cuerpoBase = "Te recordamos que tu pago vence mañana.";
                break;
            case VENCIMIENTO:
                asunto = "AlDía - Aviso de vencimiento";
                cuerpoBase = "Tu contrato o pago ha llegado a su fecha de vencimiento.";
                break;
            case MORA:
                asunto = "AlDía - Aviso de mora";
                cuerpoBase = "Tu pago se encuentra actualmente en mora.";
                break;
            case PAGO_PROXIMO:
                asunto = "AlDía - Pago próximo";
                cuerpoBase = "Tu próximo pago se acerca.";
                break;
            case PAGO_VENCIDO:
                asunto = "AlDía - Pago vencido";
                cuerpoBase = "Tu pago se encuentra vencido.";
                break;
            default:
                asunto = "AlDía - Notificación";
                cuerpoBase = "Tienes una nueva notificación.";
        }

        String mensajePersonalizado = notificacion.getMensaje();
        String cuerpo = cuerpoBase;
        if (mensajePersonalizado != null && !mensajePersonalizado.isBlank()) {
            cuerpo += "\n\nMensaje del arrendador:\n" + mensajePersonalizado;
        }
        cuerpo += "\n\nEquipo AlDía";

        return new String[]{asunto, cuerpo};
    }

    // Procesa el envío de una notificación ya guardada, según su canal
    public void procesarEnvio(Notificacion notificacion) {
        if (notificacion.getCanal() == Notificacion.CanalNotificacion.EMAIL) {
            enviarPorEmail(notificacion);
        }
        // PUSH y WHATSAPP se agregarán más adelante
    }

    private void enviarPorEmail(Notificacion notificacion) {
        try {
            Optional<Usuario> usuarioOpt = usuarioRepository.findById(notificacion.getUsuarioDestinoId());

            if (usuarioOpt.isEmpty()) {
                marcarFallida(notificacion, "No se encontró el usuario destino con id " + notificacion.getUsuarioDestinoId());
                return;
            }

            Usuario usuario = usuarioOpt.get();
            String correoDestino = usuario.getCorreo();

            if (correoDestino == null || correoDestino.isBlank()) {
                marcarFallida(notificacion, "El usuario destino no tiene correo registrado");
                return;
            }

            String[] mensaje = construirMensaje(notificacion);
            String asunto = mensaje[0];
            String cuerpo = mensaje[1];

            emailService.enviarNotificacion(correoDestino, asunto, cuerpo);

            marcarEnviada(notificacion);

        } catch (Exception e) {
            marcarFallida(notificacion, e.getMessage());
        }
    }

    private void marcarEnviada(Notificacion notificacion) {
        notificacion.setEstado(Notificacion.EstadoNotificacion.ENVIADA);
        notificacion.setFechaEnvio(LocalDateTime.now());
        notificacionRepository.save(notificacion);
    }

    private void marcarFallida(Notificacion notificacion, String detalleError) {
        notificacion.setEstado(Notificacion.EstadoNotificacion.FALLIDA);
        notificacion.setDetalleError(detalleError);
        notificacionRepository.save(notificacion);
    }
}