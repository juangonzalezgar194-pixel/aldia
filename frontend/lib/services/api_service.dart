import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
static const String baseUrl = 'http://127.0.0.1:8080/api/v1';
static const String serverUrl = 'http://127.0.0.1:8080';
  // LOGIN
  static Future<Map<String, dynamic>?> login(String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

  // REGISTRO
  static Future<bool> registrar(Map<String, dynamic> usuario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usuario),
      );
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // OBTENER CONTRATOS POR ARRENDADOR
  static Future<List<dynamic>?> obtenerContratosPorArrendador(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contratos/arrendador/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

  // OBTENER CONTRATOS POR ARRENDATARIO
  static Future<List<dynamic>?> obtenerContratosPorArrendatario(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/contratos/arrendatario/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

  // OBTENER PAGOS
  static Future<List<dynamic>?> obtenerPagos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pagos'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

  // REGISTRAR PAGO
  static Future<bool> registrarPago(Map<String, dynamic> pago) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pagos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pago),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }
// OBTENER USUARIO POR ID
  static Future<Map<String, dynamic>?> obtenerUsuarioPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }
  // ACTUALIZAR USUARIO
  static Future<bool> actualizarUsuario(int id, Map<String, dynamic> datos) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }
   // SUBIR DOCUMENTO
  static Future<bool> subirDocumento(List<int> bytes, String nombreArchivo, int contratoId) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/documentos/subir'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          bytes,
          filename: nombreArchivo,
        ),
      );
      request.fields['contratoId'] = contratoId.toString();
      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al subir documento: $e');
      return false;
    }
  }

  // OBTENER DOCUMENTOS POR CONTRATO
  static Future<List<dynamic>?> obtenerDocumentosPorContrato(int contratoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documentos/contrato/$contratoId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

  // SUBIR FOTO DE PERFIL
  static Future<Map<String, dynamic>?> subirFotoPerfil(int usuarioId, List<int> bytes, String nombreArchivo) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/usuarios/$usuarioId/foto'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'archivo',
          bytes,
          filename: nombreArchivo,
        ),
      );
      final response = await request.send();
      final respuesta = await http.Response.fromStream(response);

      if (respuesta.statusCode == 200) {
        return jsonDecode(respuesta.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error al subir foto: $e');
      return null;
    }
  }
   }