import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1/usuarios';

 static Future<Map<String, dynamic>> registrar({
  required String nombre,
  required String apellido,
  required String nombreUsuario,  // NUEVO
  required String correo,
  required String contrasena,
  required String numDocumento,
  required String telefono,
}) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'nombreUsuario': nombreUsuario,  // NUEVO
      'correo': correo,
      'contrasena': contrasena,
      'numDocumento': numDocumento,
      'telefono': telefono,
    }),
  );
  

    if (response.statusCode == 201) {
      return {'exito': true, 'data': jsonDecode(response.body)};
    } else {
      return {
        'exito': false,
        'mensaje': 'Error ${response.statusCode}: ${response.body}',
      };
    }
  }
}