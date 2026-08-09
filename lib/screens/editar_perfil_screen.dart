import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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

  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;

  Uint8List? _fotoBytes;
  String? _fotoNombre;
  bool _subiendoFoto = false;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuarioActual['nombre'] ?? '');
    _correoController = TextEditingController(text: widget.usuarioActual['correo'] ?? '');
    _telefonoController = TextEditingController(text: widget.usuarioActual['telefono'] ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (resultado != null && resultado.files.single.bytes != null) {
      setState(() {
        _fotoBytes = resultado.files.single.bytes;
        _fotoNombre = resultado.files.single.name;
      });
    }
  }

  Future<void> _subirFoto() async {
    if (_fotoBytes == null || _fotoNombre == null) return;

    setState(() => _subiendoFoto = true);

    final resultado = await ApiService.subirFotoPerfil(
      widget.usuarioId,
      _fotoBytes!,
      _fotoNombre!,
    );

    setState(() => _subiendoFoto = false);

    if (resultado != null && mounted) {
      setState(() {
        widget.usuarioActual['fotoUrl'] = resultado['fotoUrl'];
        _fotoBytes = null;
        _fotoNombre = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto actualizada')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo subir la foto')),
      );
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    final datos = {
      'nombre': _nombreController.text.trim(),
      'correo': _correoController.text.trim(),
      'telefono': _telefonoController.text.trim(),
    };

    final exito = await ApiService.actualizarUsuario(widget.usuarioId, datos);

    if (!mounted) return;

    if (exito) {
      final actualizado = Map<String, dynamic>.from(widget.usuarioActual);
      actualizado.addAll(datos);
      Navigator.pop(context, actualizado);
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.azulPrincipal,
                      backgroundImage: _fotoBytes != null
                          ? MemoryImage(Uint8List.fromList(_fotoBytes!))
                          : (widget.usuarioActual['fotoUrl'] != null
                              ? NetworkImage('${ApiService.serverUrl}${widget.usuarioActual['fotoUrl']}')
                              : null) as ImageProvider?,
                      child: (_fotoBytes == null && widget.usuarioActual['fotoUrl'] == null)
                          ? Text(
                              (widget.usuarioActual['nombre'] ?? 'U').toString().isNotEmpty
                                  ? widget.usuarioActual['nombre'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(fontSize: 36, color: Colors.white, fontFamily: 'Nunito'),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _seleccionarFoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.esmeralda,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_fotoBytes != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _subiendoFoto ? null : _subirFoto,
                    child: _subiendoFoto
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Guardar foto', style: TextStyle(fontFamily: 'Nunito')),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa tu correo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontFamily: 'Nunito'),
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}