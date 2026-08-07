// Dependencias necesarias en pubspec.yaml:
//   file_picker: ^8.0.0   -> seleccionar archivos desde el portátil o el celular
//   http: ^1.2.0          -> llamadas al backend
//   url_launcher: ^6.2.0  -> abrir/ver el comprobante descargado
//   intl: ^0.19.0         -> formatear fechas

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'comprobante_model.dart';
import '../services/comprobante_service.dart';

class AlDiaColors {
  static const navy = Color(0xFF1B2A4A);
  static const teal = Color(0xFF1BA98C);
  static const orange = Color(0xFFF2994A);
  static const background = Color(0xFFF5F7FA);
}

class ComprobantesScreen extends StatefulWidget {
  final dynamic contratoId; // acepta int o String según venga del JSON de tu API
  final String usuarioActual; // nombre o correo del usuario logueado

  const ComprobantesScreen({
    super.key,
    required this.contratoId,
    required this.usuarioActual,
  });

  @override
  State<ComprobantesScreen> createState() => _ComprobantesScreenState();
}

class _ComprobantesScreenState extends State<ComprobantesScreen> {
  final ComprobanteService _service = ComprobanteService();

  List<Comprobante> _comprobantes = [];
  bool _cargando = true;
  bool _subiendo = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarComprobantes();
  }

  Future<void> _cargarComprobantes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final idContrato = widget.contratoId is int
          ? widget.contratoId as int
          : int.parse(widget.contratoId.toString());
      final lista = await _service.listarPorContrato(idContrato);
      setState(() => _comprobantes = lista);
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar los comprobantes.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _seleccionarYSubirArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true, // necesario para obtener los bytes en web y mobile
    );

    if (resultado == null || resultado.files.isEmpty) return;

    final archivo = resultado.files.first;
    if (archivo.bytes == null) {
      _mostrarMensaje('No se pudo leer el archivo seleccionado.');
      return;
    }

    setState(() => _subiendo = true);
    try {
      final idContrato = widget.contratoId is int
          ? widget.contratoId as int
          : int.parse(widget.contratoId.toString());
      await _service.subirComprobante(
        contratoId: idContrato,
        subidoPor: widget.usuarioActual,
        nombreArchivo: archivo.name,
        bytes: archivo.bytes!,
      );
      _mostrarMensaje('Comprobante subido correctamente.');
      await _cargarComprobantes();
    } catch (e) {
      _mostrarMensaje('Error al subir el comprobante. Intenta de nuevo.');
    } finally {
      setState(() => _subiendo = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _abrirComprobante(Comprobante comprobante) async {
    // Ajusta el dominio base si urlDescarga es una ruta relativa.
    final url = Uri.parse(comprobante.urlDescarga);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _mostrarMensaje('No se pudo abrir el comprobante.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AlDiaColors.background,
      appBar: AppBar(
        title: const Text('Comprobantes'),
        backgroundColor: Colors.white,
        foregroundColor: AlDiaColors.navy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comprobantes de pago',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AlDiaColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Capturas o PDF visibles para arrendador y arrendatario.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            _BotonSubirComprobante(
              subiendo: _subiendo,
              onTap: _seleccionarYSubirArchivo,
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildListado()),
          ],
        ),
      ),
    );
  }

  Widget _buildListado() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: AlDiaColors.teal));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_comprobantes.isEmpty) {
      return Center(
        child: Text(
          'Todavía no hay comprobantes subidos.',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.separated(
      itemCount: _comprobantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final comprobante = _comprobantes[index];
        return _ComprobanteTile(
          comprobante: comprobante,
          onTap: () => _abrirComprobante(comprobante),
        );
      },
    );
  }
}

class _BotonSubirComprobante extends StatelessWidget {
  final bool subiendo;
  final VoidCallback onTap;

  const _BotonSubirComprobante({required this.subiendo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: subiendo ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AlDiaColors.teal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (subiendo)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(Icons.upload_file_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              subiendo ? 'Subiendo...' : 'Subir comprobante (imagen o PDF)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComprobanteTile extends StatefulWidget {
  final Comprobante comprobante;
  final VoidCallback onTap;

  const _ComprobanteTile({required this.comprobante, required this.onTap});

  @override
  State<_ComprobanteTile> createState() => _ComprobanteTileState();
}

class _ComprobanteTileState extends State<_ComprobanteTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.comprobante;
    final fecha = DateFormat('dd MMM yyyy, hh:mm a', 'es_CO').format(c.fechaSubida);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering ? AlDiaColors.orange : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.08 : 0.04),
                blurRadius: _hovering ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (c.esPdf ? AlDiaColors.navy : AlDiaColors.teal).withOpacity(0.12),
                ),
                child: Icon(
                  c.esPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                  color: c.esPdf ? AlDiaColors.navy : AlDiaColors.teal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nombreArchivo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AlDiaColors.navy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Subido por ${c.subidoPor} · $fecha',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}