package com.aldia.aldia_backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class EmailService {

    // Se toma automáticamente de la variable de entorno RESEND_API_KEY en Railway
    @Value("${RESEND_API_KEY}")
    private String resendApiKey;

    // Remitente de pruebas de Resend (mientras no verifiquemos un dominio propio)
    private static final String REMITENTE = "AlDía <onboarding@resend.dev>";
    private static final String RESEND_URL = "https://api.resend.com/emails";

    private final RestTemplate restTemplate = new RestTemplate();

    public void enviarCodigoRecuperacion(String correoDestino, String codigo) {
        String cuerpo =
            "Hola,\n\n" +
            "Recibimos una solicitud para restablecer tu contraseña en AlDía.\n\n" +
            "Tu código de verificación es: " + codigo + "\n\n" +
            "Este código expira en 15 minutos.\n\n" +
            "Si no solicitaste este cambio, ignora este correo.\n\n" +
            "Equipo AlDía";

        enviarCorreo(correoDestino, "AlDía - Código de recuperación de contraseña", cuerpo);
    }

    public void enviarNotificacion(String correoDestino, String asunto, String cuerpo) {
        enviarCorreo(correoDestino, asunto, cuerpo);
    }

    private void enviarCorreo(String correoDestino, String asunto, String cuerpoTexto) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(resendApiKey);

        Map<String, Object> body = new HashMap<>();
        body.put("from", REMITENTE);
        body.put("to", new String[] { correoDestino });
        body.put("subject", asunto);
        // Resend recibe el cuerpo como HTML; convertimos los saltos de línea para que se vea igual que en texto plano
        body.put("html", cuerpoTexto.replace("\n", "<br>"));

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

        try {
            restTemplate.postForEntity(RESEND_URL, request, String.class);
        } catch (Exception e) {
            // Relanzamos como RuntimeException para que el código que llama
            // (el que actualiza el campo detalle_error en la tabla notificacion)
            // siga capturando el error igual que antes con JavaMailSender.
            throw new RuntimeException("Error al enviar correo con Resend: " + e.getMessage(), e);
        }
    }
}