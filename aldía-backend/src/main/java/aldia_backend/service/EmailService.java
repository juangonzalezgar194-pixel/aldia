package com.aldia.aldia_backend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    public void enviarCodigoRecuperacion(String correoDestino, String codigo) {
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setFrom("juangonzalezgar194@gmail.com");
        mensaje.setTo(correoDestino);
        mensaje.setSubject("AlDía - Código de recuperación de contraseña");
        mensaje.setText(
            "Hola,\n\n" +
            "Recibimos una solicitud para restablecer tu contraseña en AlDía.\n\n" +
            "Tu código de verificación es: " + codigo + "\n\n" +
            "Este código expira en 15 minutos.\n\n" +
            "Si no solicitaste este cambio, ignora este correo.\n\n" +
            "Equipo AlDía"
        );
        mailSender.send(mensaje);
    }
}