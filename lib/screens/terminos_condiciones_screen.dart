import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';

class TerminosCondicionesScreen extends StatelessWidget {
  const TerminosCondicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.esmeralda,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Términos y Condiciones de Uso – AlDía',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: 21 de agosto de 2026',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 20),

            _seccion(
              '1. Aceptación de los términos',
              'Al registrarte y utilizar la aplicación AlDía, aceptas cumplir '
                  'con estos Términos y Condiciones. Si no estás de acuerdo con '
                  'alguno de los puntos aquí descritos, no debes utilizar la '
                  'aplicación.',
            ),
            _seccion(
              '2. Descripción del servicio',
              'AlDía es un sistema de gestión y notificación de pagos de '
                  'arriendo, diseñado para facilitar la comunicación entre '
                  'arrendadores y arrendatarios, así como el seguimiento de '
                  'contratos y pagos.',
            ),
            _seccion(
              '3. Registro y cuenta de usuario',
              'Para usar la aplicación, debes proporcionar información veraz '
                  'y actualizada. Eres responsable de mantener la '
                  'confidencialidad de tu contraseña y de toda actividad '
                  'realizada desde tu cuenta.',
            ),
            _seccion(
              '4. Uso adecuado de la aplicación',
              'Te comprometes a utilizar AlDía únicamente para fines lícitos '
                  'relacionados con la gestión de arriendos, sin realizar '
                  'actividades que puedan dañar, sobrecargar o afectar el '
                  'funcionamiento del sistema.',
            ),
            _seccion(
              '5. Tratamiento de datos personales',
              'La información que proporcionas (nombre, correo, datos de '
                  'contrato, pagos, etc.) será utilizada exclusivamente para '
                  'el funcionamiento de la plataforma, conforme a la '
                  'normatividad de protección de datos aplicable.',
            ),
            _seccion(
              '6. Responsabilidad',
              'AlDía facilita la gestión de información entre arrendador y '
                  'arrendatario, pero no es parte del contrato de '
                  'arrendamiento en sí. Cualquier disputa relacionada con el '
                  'contrato deberá resolverse directamente entre las partes.',
            ),
            _seccion(
              '7. Modificaciones',
              'Estos Términos y Condiciones pueden actualizarse '
                  'periódicamente. Se notificará a los usuarios sobre '
                  'cambios importantes a través de la aplicación.',
            ),
            _seccion(
              '8. Contacto',
              'Para dudas o inquietudes sobre estos términos, puedes '
                  'contactarnos a través de los canales de soporte '
                  'disponibles dentro de la aplicación.',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            contenido,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}