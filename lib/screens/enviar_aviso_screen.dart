import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnviarAvisoScreen extends StatefulWidget {
  const EnviarAvisoScreen({super.key});

  @override
  State<EnviarAvisoScreen> createState() => _EnviarAvisoScreenState();
}

class _EnviarAvisoScreenState extends State<EnviarAvisoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mensajeController = TextEditingController();

  String? _tipoSeleccionado;
  String? _canalSeleccionado;
  bool _enviando = false;

  // ID de usuario temporal hasta conectar login
  final int _usuarioId = 1;
  final int _pagoId = 1;

  final List<Map<String, String>> _tipos = [
    {'label': 'Recordatorio 3 días', 'value': 'RECORDATORIO_3_DIAS'},
    {'label': 'Recordatorio 1 día', 'value': 'RECORDATORIO_1_DIA'},
    {'label': 'Vencimiento', 'value': 'VENCIMIENTO'},
    {'label': 'Mora', 'value': 'MORA'},
  ];

  final List<Map<String, String>> _canales = [
    {'label': 'Email', 'value': 'EMAIL'},
    {'label': 'Push', 'value': 'PUSH'},
    {'label': 'WhatsApp', 'value': 'WHATSAPP'},
  ];

  Future<void> _enviarAviso() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);

    try {
      final response = await http.post(
        Uri.parse('https://aldia-production-ff3c.up.railway.app/api/notificaciones'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pagoId': _pagoId,
          'usuarioId': _usuarioId,
          'tipo': _tipoSeleccionado,
          'canal': _canalSeleccionado,
          'estado': 'PENDIENTE',
          'fechaProgramada': DateTime.now().toIso8601String().substring(0, 19),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Aviso enviado correctamente!'),
            backgroundColor: Color(0xFFFF6B00),
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _tipoSeleccionado = null;
          _canalSeleccionado = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor')),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Aviso'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de aviso',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                hint: const Text('Selecciona el tipo'),
                items: _tipos
                    .map((t) => DropdownMenuItem(
                        value: t['value'], child: Text(t['label']!)))
                    .toList(),
                onChanged: (val) => setState(() => _tipoSeleccionado = val),
                validator: (val) =>
                    val == null ? 'Selecciona un tipo de aviso' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Canal de envío',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _canalSeleccionado,
                hint: const Text('Selecciona el canal'),
                items: _canales
                    .map((c) => DropdownMenuItem(
                        value: c['value'], child: Text(c['label']!)))
                    .toList(),
                onChanged: (val) => setState(() => _canalSeleccionado = val),
                validator: (val) =>
                    val == null ? 'Selecciona un canal' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _enviando ? null : _enviarAviso,
                  icon: _enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.notifications_active),
                  label: Text(
                    _enviando ? 'Enviando...' : 'Enviar Aviso',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}