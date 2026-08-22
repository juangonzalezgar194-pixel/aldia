import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/confirmacion_pago_model.dart';

class ConfirmacionPagoService {
  // Misma base que comprobante_service.dart, cambiando el recurso.
  static const String baseUrl = 'https://api.aldiaapp.org/api/v1/confirmaciones-pago';

  /// El arrendatario reporta que pagó en efectivo. Queda PENDIENTE.
  Future<ConfirmacionPago> reportarPagoEfectivo({
    required int contratoId,
    required double valor,
    required String nombrePagador,
    required DateTime fechaPago,
  }) async {
    final uri = Uri.parse('$baseUrl/efectivo/$contratoId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'valor': valor,
        'nombrePagador': nombrePagador,
        'fechaPago': fechaPago.toIso8601String().split('T').first, // yyyy-MM-dd
      }),
    );

    if (response.statusCode == 200) {
      return ConfirmacionPago.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('No se pudo reportar el pago en efectivo: ${response.body}');
    }
  }

  /// El arrendador confirma (aprueba) un pago en efectivo reportado.
  Future<ConfirmacionPago> confirmarPago(int id) async {
    final uri = Uri.parse('$baseUrl/$id/confirmar');
    final response = await http.put(uri);

    if (response.statusCode == 200) {
      return ConfirmacionPago.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('No se pudo confirmar el pago: ${response.body}');
    }
  }

  /// Todas las confirmaciones de un contrato.
  Future<List<ConfirmacionPago>> listarPorContrato(int contratoId) async {
    final uri = Uri.parse('$baseUrl/contrato/$contratoId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ConfirmacionPago.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron cargar las confirmaciones.');
    }
  }

  /// Pagos en efectivo pendientes de confirmar (para la pantalla del arrendador).
  Future<List<ConfirmacionPago>> listarPendientes(int contratoId) async {
    final uri = Uri.parse('$baseUrl/contrato/$contratoId/pendientes');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ConfirmacionPago.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron cargar los pagos pendientes.');
    }
  }
}