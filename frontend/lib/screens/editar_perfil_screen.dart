import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final int usuarioId;
  final Map<String, dynamic> usuarioActual;

  const EditarPerfilScreen({
    super.key,
    required this.usuarioId,
    required this.usuarioActual,
  });

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _telefonoCtrl;

  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.usuarioActual['nombre'] ?? '');
    _apellidoCtrl = TextEditingController(text: widget.usuarioActual['apellido'] ?? '');
    _correoCtrl = TextEditingController(text: widget.usuarioActual['correo'] ?? '');
    _telefonoCtrl = TextEditingController(text: widget.usuarioActual['telefono'] ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    final datos = {
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'activo': widget.usuarioActual['activo'] ?? true,
    };

    final exito = await ApiService.actualizarUsuario(widget.usuarioId, datos);

    if (!mounted) return;

    if (exito) {
      // Devolvemos los datos actualizados para refrescar la pantalla anterior
      Navigator.pop(context, {...widget.usuarioActual, ...datos});
    } else {
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.blanco,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.azulPrincipal),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: AppColors.azulPrincipal,
            fontWeight: FontWeight.w800,
            fontFamily: 'Nunito',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontFamily: 'Nunito'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoCtrl,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'El apellido es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
                  final regex = RegExp(r'^[\w.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                  if (!regex.hasMatch(v.trim())) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'El teléfono es obligatorio' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}