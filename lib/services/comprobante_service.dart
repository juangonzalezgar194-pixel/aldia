import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/comprobante_model.dart';
class ComprobanteService {
  // Ajusta esta URL base a la de tu backend desplegado en Railway.
static const String baseUrl = 'https://api.aldiaapp.org/api/v1/comprobantes';
  /// Sube un comprobante (imagen o PDF) para un contrato.
  /// [bytes] son los bytes del archivo leídos con file_picker.
  Future<Comprobante> subirComprobante({
    required int contratoId,
    required String subidoPor,
    required String nombreArchivo,
    required List<int> bytes,
  }) async {
    final uri = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['contratoId'] = contratoId.toString()
      ..fields['subidoPor'] = subidoPor
      ..files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          bytes,
          filename: nombreArchivo,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Comprobante.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('No se pudo subir el comprobante: ${response.body}');
    }
  }

  /// Lista los comprobantes de un contrato (visibles para ambos roles).
  Future<List<Comprobante>> listarPorContrato(int contratoId) async {
    final uri = Uri.parse('$baseUrl/contrato/$contratoId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Comprobante.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron cargar los comprobantes.');
    }
  }
}