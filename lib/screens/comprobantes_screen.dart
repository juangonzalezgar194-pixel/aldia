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
import 'confirmacion_pago_model.dart';
import '../services/comprobante_service.dart';
import '../services/confirmacion_pago_service.dart';

class AlDiaColors {
  static const navy = Color(0xFF1B2A4A);
  static const teal = Color(0xFF1BA98C);
  static const orange = Color(0xFFF2994A);
  static const background = Color(0xFFF5F7FA);
}

class ComprobantesScreen extends StatefulWidget {
  final dynamic contratoId; // acepta int o String según venga del JSON de tu API
  final String usuarioActual; // nombre o correo del usuario logueado
  final bool esArrendador; // true = ve pagos por confirmar, false = puede reportar pago en efectivo

  const ComprobantesScreen({
    super.key,
    required this.contratoId,
    required this.usuarioActual,
    required this.esArrendador,
  });

  @override
  State<ComprobantesScreen> createState() => _ComprobantesScreenState();
}

class _ComprobantesScreenState extends State<ComprobantesScreen> {
  final ComprobanteService _service = ComprobanteService();
  final ConfirmacionPagoService _pagoService = ConfirmacionPagoService();

  List<Comprobante> _comprobantes = [];
  List<ConfirmacionPago> _pendientes = [];
  bool _cargando = true;
  bool _subiendo = false;
  bool _reportandoPago = false;
  String? _error;

  int get _contratoIdInt => widget.contratoId is int
      ? widget.contratoId as int
      : int.parse(widget.contratoId.toString());

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _service.listarPorContrato(_contratoIdInt);
      List<ConfirmacionPago> pendientes = [];
      if (widget.esArrendador) {
        pendientes = await _pagoService.listarPendientes(_contratoIdInt);
      }
      setState(() {
        _comprobantes = lista;
        _pendientes = pendientes;
      });
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
      await _service.subirComprobante(
        contratoId: _contratoIdInt,
        subidoPor: widget.usuarioActual,
        nombreArchivo: archivo.name,
        bytes: archivo.bytes!,
      );
      _mostrarMensaje('Comprobante subido correctamente.');
      await _cargarTodo();
    } catch (e) {
      _mostrarMensaje('Error al subir el comprobante. Intenta de nuevo.');
    } finally {
      setState(() => _subiendo = false);
    }
  }

  // ── FORMULARIO: reportar pago en efectivo (arrendatario) ──────────
  void _mostrarFormularioPagoEfectivo() {
    final formKey = GlobalKey<FormState>();
    final valorCtrl = TextEditingController();
    final nombreCtrl = TextEditingController(text: widget.usuarioActual);
    final fechaCtrl = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    DateTime fechaSeleccionada = DateTime.now();
    bool enviando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDE3EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AlDiaColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.payments_rounded, color: AlDiaColors.orange, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Reportar pago en efectivo',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AlDiaColors.navy),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'El arrendador deberá confirmar este pago.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: valorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 14),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa el valor pagado';
                          if (double.tryParse(v) == null) return 'Ingresa un número válido';
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Valor pagado',
                          prefixIcon: const Icon(Icons.attach_money_rounded, color: AlDiaColors.navy, size: 20),
                          filled: true,
                          fillColor: AlDiaColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: fechaCtrl,
                        readOnly: true,
                        style: const TextStyle(fontSize: 14),
                        validator: (v) => (v == null || v.isEmpty) ? 'Selecciona la fecha' : null,
                        decoration: InputDecoration(
                          labelText: 'Fecha del pago',
                          prefixIcon: const Icon(Icons.calendar_today_rounded, color: AlDiaColors.navy, size: 20),
                          filled: true,
                          fillColor: AlDiaColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: fechaSeleccionada,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (fecha != null) {
                            fechaSeleccionada = fecha;
                            fechaCtrl.text = DateFormat('yyyy-MM-dd').format(fecha);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: nombreCtrl,
                        style: const TextStyle(fontSize: 14),
                        validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el nombre de quien pagó' : null,
                        decoration: InputDecoration(
                          labelText: 'Nombre de quien realizó el pago',
                          prefixIcon: const Icon(Icons.person_rounded, color: AlDiaColors.navy, size: 20),
                          filled: true,
                          fillColor: AlDiaColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: enviando
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => enviando = true);
                                  try {
                                    await _pagoService.reportarPagoEfectivo(
                                      contratoId: _contratoIdInt,
                                      valor: double.parse(valorCtrl.text),
                                      nombrePagador: nombreCtrl.text.trim(),
                                      fechaPago: fechaSeleccionada,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    _mostrarMensaje('Pago reportado. Quedará pendiente hasta que el arrendador lo confirme.');
                                    await _cargarTodo();
                                  } catch (e) {
                                    setModalState(() => enviando = false);
                                    _mostrarMensaje('No se pudo reportar el pago. Intenta de nuevo.');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AlDiaColors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: enviando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  'Enviar reporte de pago',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── ARRENDADOR: confirmar un pago en efectivo pendiente ──────────
  Future<void> _confirmarPagoEfectivo(ConfirmacionPago pago) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Confirmar este pago?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          '${pago.nombrePagador ?? 'Alguien'} reportó un pago de '
          '\$${pago.valor?.toStringAsFixed(0) ?? '-'} el '
          '${pago.fechaPago != null ? DateFormat('dd MMM yyyy', 'es_CO').format(pago.fechaPago!) : '-'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar', style: TextStyle(color: AlDiaColors.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await _pagoService.confirmarPago(pago.id);
      _mostrarMensaje('Pago confirmado.');
      await _cargarTodo();
    } catch (e) {
      _mostrarMensaje('No se pudo confirmar el pago.');
    }
  }

  Future<void> _confirmarEliminarComprobante(Comprobante comprobante) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar comprobante?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Se eliminará "${comprobante.nombreArchivo}" permanentemente. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await _service.eliminarComprobante(comprobante.id);
      _mostrarMensaje('Comprobante eliminado.');
      await _cargarTodo();
    } catch (e) {
      _mostrarMensaje('Error al eliminar el comprobante.');
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
            Row(
              children: [
                Expanded(
                  child: _BotonAccion(
                    icono: Icons.upload_file_rounded,
                    texto: _subiendo ? 'Subiendo...' : 'Subir comprobante',
                    color: AlDiaColors.teal,
                    cargando: _subiendo,
                    onTap: _seleccionarYSubirArchivo,
                  ),
                ),
                if (!widget.esArrendador) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotonAccion(
                      icono: Icons.payments_rounded,
                      texto: 'Pago en efectivo',
                      color: AlDiaColors.orange,
                      cargando: false,
                      onTap: _mostrarFormularioPagoEfectivo,
                    ),
                  ),
                ],
              ],
            ),
            if (widget.esArrendador && _pendientes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Pagos en efectivo por confirmar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AlDiaColors.navy),
              ),
              const SizedBox(height: 10),
              ..._pendientes.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaPagoPendiente(
                    pago: p,
                    onConfirmar: () => _confirmarPagoEfectivo(p),
                  ),
                ),
              ),
            ],
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
          onDelete: () => _confirmarEliminarComprobante(comprobante),
        );
      },
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final bool cargando;
  final VoidCallback onTap;

  const _BotonAccion({
    required this.icono,
    required this.texto,
    required this.color,
    required this.cargando,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cargando ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (cargando)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(icono, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPagoPendiente extends StatelessWidget {
  final ConfirmacionPago pago;
  final VoidCallback onConfirmar;

  const _TarjetaPagoPendiente({required this.pago, required this.onConfirmar});

  @override
  Widget build(BuildContext context) {
    final fecha = pago.fechaPago != null
        ? DateFormat('dd MMM yyyy', 'es_CO').format(pago.fechaPago!)
        : '-';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AlDiaColors.orange.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AlDiaColors.orange.withOpacity(0.12),
            ),
            child: const Icon(Icons.payments_rounded, color: AlDiaColors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${pago.valor?.toStringAsFixed(0) ?? '-'} · ${pago.nombrePagador ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AlDiaColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fecha reportada: $fecha',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onConfirmar,
            style: TextButton.styleFrom(
              backgroundColor: AlDiaColors.teal.withOpacity(0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirmar', style: TextStyle(color: AlDiaColors.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ComprobanteTile extends StatefulWidget {
  final Comprobante comprobante;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ComprobanteTile({
    required this.comprobante,
    required this.onTap,
    required this.onDelete,
  });

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
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onDelete,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  child: const Text(
                    'X',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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