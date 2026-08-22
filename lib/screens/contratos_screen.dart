import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ContratosScreen extends StatefulWidget {
  final int usuarioId;

  const ContratosScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<ContratosScreen> createState() => _ContratosScreenState();
}

class _ContratosScreenState extends State<ContratosScreen> {
  List<dynamic> _contratos = [];
  bool _cargando = true;

  final Map<int, List<dynamic>> _documentosPorContrato = {};
  final Map<int, bool> _cargandoDocumentos = {};
  final Map<int, bool> _subiendo = {};
  final Map<int, bool> _eliminando = {};

  @override
  void initState() {
    super.initState();
    _cargarContratos();
  }

  Future<void> _cargarContratos() async {
    final contratos = await ApiService.obtenerContratosPorArrendador(widget.usuarioId);
    setState(() {
      _contratos = contratos ?? [];
      _cargando = false;
    });

    for (final contrato in _contratos) {
      final contratoId = contrato['id'] ?? 0;
      _cargarDocumentos(contratoId);
    }
  }

  Future<void> _cargarDocumentos(int contratoId) async {
    setState(() => _cargandoDocumentos[contratoId] = true);

    final documentos = await ApiService.obtenerDocumentosPorContrato(contratoId);

    if (!mounted) return;
    setState(() {
      _documentosPorContrato[contratoId] = documentos ?? [];
      _cargandoDocumentos[contratoId] = false;
    });
  }

  Future<void> _subirDocumento(int contratoId) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) return;

    final archivo = resultado.files.first;
    if (archivo.bytes == null) return;

    setState(() => _subiendo[contratoId] = true);

    final exito = await ApiService.subirDocumento(
      archivo.bytes!,
      archivo.name,
      contratoId,
    );

    if (!mounted) return;
    setState(() => _subiendo[contratoId] = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito
            ? '✅ Documento subido correctamente'
            : '❌ Error al subir el documento'),
        backgroundColor: exito ? AppColors.esmeralda : Colors.red,
      ),
    );

    if (exito) {
      await _cargarDocumentos(contratoId);
    }
  }

  Future<void> _confirmarEliminarDocumento(int contratoId, dynamic doc) async {
    final nombreDoc = doc['nombre'] ?? 'este documento';
    final documentoId = doc['id'];
    if (documentoId == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Eliminar documento?',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Se eliminará "$nombreDoc" permanentemente. Esta acción no se puede deshacer.',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontFamily: 'Nunito', color: AppColors.grisMedio),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontFamily: 'Nunito', color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() => _eliminando[documentoId] = true);

    final exito = await ApiService.eliminarDocumento(documentoId);

    if (!mounted) return;
    setState(() => _eliminando[documentoId] = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exito
            ? '🗑️ Documento eliminado'
            : '❌ Error al eliminar el documento'),
        backgroundColor: exito ? AppColors.esmeralda : Colors.red,
      ),
    );

    if (exito) {
      await _cargarDocumentos(contratoId);
    }
  }

  Future<void> _abrirDocumento(dynamic doc) async {
    final urlRelativa = doc['url'] ?? '';
    if (urlRelativa.isEmpty) return;

    final urlCompleta = '${ApiService.serverUrl}/$urlRelativa';

    final uri = Uri.parse(urlCompleta);
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _iconoPorTipo(String? tipo) {
    if (tipo == null) return Icons.insert_drive_file_rounded;
    if (tipo.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (tipo.contains('image')) return Icons.image_rounded;
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Contratos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.azulPrincipal,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gestiona y sube documentos de tus contratos',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grisMedio,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 24),
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : _contratos.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.home_work_outlined,
                              size: 64, color: AppColors.grisMedio),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay contratos registrados',
                            style: TextStyle(
                              color: AppColors.grisMedio,
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _contratos.map((contrato) {
                        final contratoId = contrato['id'] ?? 0;
                        final dias = contrato['fechaFin'] != null
                            ? DateTime.parse(contrato['fechaFin'])
                                .difference(DateTime.now())
                                .inDays
                            : 999;
                        final color = dias <= 30
                            ? AppColors.naranja
                            : AppColors.esmeralda;

                        final documentos = _documentosPorContrato[contratoId] ?? [];
                        final cargandoDocs = _cargandoDocumentos[contratoId] ?? false;
                        final subiendoEste = _subiendo[contratoId] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.blanco,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A1A3A5C),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.azulPrincipal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.home_work_rounded,
                                        color: AppColors.azulPrincipal,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Contrato #$contratoId',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.azulPrincipal,
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                          Text(
                                            'Inmueble #${contrato['inmuebleId']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grisMedio,
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        contrato['estado'] ?? 'ACTIVO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: AppColors.azulClaro),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 13, color: AppColors.grisMedio),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Inicio: ${contrato['fechaInicio'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grisMedio,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.event_rounded,
                                        size: 13, color: AppColors.grisMedio),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Fin: ${contrato['fechaFin'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grisMedio,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                if (cargandoDocs)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                else if (documentos.isNotEmpty) ...[
                                  const Text(
                                    'Documentos subidos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.grisMedio,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...documentos.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final doc = entry.value;
                                    final documentoId = doc['id'];
                                    final eliminandoEste =
                                        _eliminando[documentoId] ?? false;

                                    return Padding(
                                      key: ValueKey('doc_${contratoId}_${documentoId ?? index}'),
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.grisClaro,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () => _abrirDocumento(doc),
                                                borderRadius: BorderRadius.circular(10),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 10),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        _iconoPorTipo(doc['tipo']),
                                                        size: 18,
                                                        color: AppColors.azulPrincipal,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          doc['nombre'] ?? 'Documento',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontFamily: 'Nunito',
                                                            fontWeight: FontWeight.w600,
                                                            color: AppColors.azulPrincipal,
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.open_in_new_rounded,
                                                        size: 16,
                                                        color: AppColors.grisMedio,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 4),
                                              child: eliminandoEste
                                                  ? const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 14),
                                                      child: SizedBox(
                                                        height: 16,
                                                        width: 16,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                    )
                                                  : Tooltip(
                                                      message: 'Eliminar documento',
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(20),
                                                        onTap: () =>
                                                            _confirmarEliminarDocumento(contratoId, doc),
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
                                                              fontFamily: 'Nunito',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 6),
                                ],

                                ElevatedButton.icon(
                                  onPressed: subiendoEste
                                      ? null
                                      : () => _subirDocumento(contratoId),
                                  icon: subiendoEste
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.upload_file_rounded, size: 18),
                                  label: Text(
                                    subiendoEste ? 'Subiendo...' : 'Subir documento',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.azulPrincipal,
                                    minimumSize: const Size(double.infinity, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}