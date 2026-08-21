package com.aldia.aldia_backend.service;

import jakarta.annotation.PostConstruct;
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

    // MODO PRUEBAS: mientras no tengamos dominio propio verificado en Resend,
    // todos los correos se redirigen a esta casilla en vez de al destinatario real.
    // Poner en "false" (o borrar la variable) apenas se verifique el dominio.
    @Value("${EMAIL_MODO_PRUEBA:true}")
    private boolean modoPrueba;

    @Value("${EMAIL_CORREO_PRUEBAS:juangonzalezgar194@gmail.com}")
    private String correoPruebas;

    // Remitente con dominio propio ya verificado en Resend (api.aldiaapp.org)
    private static final String REMITENTE = "AlDía <notificaciones@api.aldiaapp.org>";
    private static final String RESEND_URL = "https://api.resend.com/emails";

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Se ejecuta UNA vez, justo al terminar de arrancar este bean, y deja
     * en los logs de Railway (pestaña Deployments -> View logs, o Console)
     * una línea clarísima con el valor REAL que el servidor está usando.
     *
     * Esto es la fuente de verdad: si aquí dice "true", no importa lo que
     * diga el panel de Variables de Railway — el proceso que está corriendo
     * ahora mismo sigue en modo prueba y hay que investigar por qué (variable
     * mal escrita, servicio equivocado, redeploy que no se aplicó, etc).
     */
    @PostConstruct
    public void logConfiguracionAlArrancar() {
        System.out.println("=================================================");
        System.out.println("🔧 EmailService iniciado");
        System.out.println("🔧 EMAIL_MODO_PRUEBA (valor real usado) = " + modoPrueba);
        if (modoPrueba) {
            System.out.println("🔧 TODOS los correos se están redirigiendo a: " + correoPruebas);
        } else {
            System.out.println("🔧 Los correos se envían al destinatario real (modo producción)");
        }
        System.out.println("=================================================");
    }

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

    public void enviarCodigoActivacion(String correoDestino, String nombreArrendatario, String codigo) {
        String cuerpo =
            "Hola " + nombreArrendatario + ",\n\n" +
            "Tu arrendador acaba de registrar un contrato a tu nombre en AlDía.\n\n" +
            "Ya tienes una cuenta creada. Para activarla y poder ingresar, usa este código:\n\n" +
            "Tu código de activación es: " + codigo + "\n\n" +
            "Este código expira en 15 minutos. Ingresa a la app, selecciona 'Olvidé mi contraseña' " +
            "con tu correo (" + correoDestino + ") y usa este código para crear tu contraseña.\n\n" +
            "Equipo AlDía";

        enviarCorreo(correoDestino, "AlDía - Activa tu cuenta", cuerpo);
    }

    public void enviarNotificacion(String correoDestino, String asunto, String cuerpo) {
        enviarCorreo(correoDestino, asunto, cuerpo);
    }

    private void enviarCorreo(String correoDestino, String asunto, String cuerpoTexto) {
        String destinatarioReal = correoDestino;
        String asuntoFinal = asunto;
        String cuerpoFinal = cuerpoTexto;

        // Log por cada envío: así, además del log de arranque, ves en cada
        // intento exactamente qué decidió el código con este correo puntual.
        System.out.println("📧 Intentando enviar correo | modoPrueba=" + modoPrueba
                + " | destinatarioSolicitado=" + correoDestino);

        if (modoPrueba) {
            // Redirigimos todo a la casilla de pruebas, pero dejamos claro
            // en el asunto y el cuerpo para quién era el correo originalmente.
            destinatarioReal = correoPruebas;
            asuntoFinal = "[PRUEBA -> " + correoDestino + "] " + asunto;
            cuerpoFinal = "(Correo de prueba. Destinatario real: " + correoDestino + ")\n\n" + cuerpoTexto;
        }

        System.out.println("📧 Enviando realmente a: " + destinatarioReal);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(resendApiKey);

        Map<String, Object> body = new HashMap<>();
        body.put("from", REMITENTE);
        body.put("to", new String[] { destinatarioReal });
        body.put("subject", asuntoFinal);
        // Resend recibe el cuerpo como HTML; convertimos los saltos de línea para que se vea igual que en texto plano
        body.put("html", cuerpoFinal.replace("\n", "<br>"));

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