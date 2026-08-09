import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'https://aldia-production-ff3c.up.railway.app/api/v1/usuarios';

 static Future<Map<String, dynamic>> registrar({
  required String nombre,
  required String apellido,
  required String nombreUsuario,
  required String correo,
  required String contrasena,
  required String numDocumento,
  required String telefono,
  required String rol, // NUEVO: 'ARRENDADOR' o 'ARRENDATARIO'
}) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'nombreUsuario': nombreUsuario,
      'correo': correo,
      'contrasena': contrasena,
      'numDocumento': numDocumento,
      'telefono': telefono,
      'rol': rol, // NUEVO
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