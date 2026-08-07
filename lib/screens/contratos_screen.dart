import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';
import 'package:file_picker/file_picker.dart';

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
  }

  Future<void> _subirDocumento(int contratoId) async {
    final resultado = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  withData: true,
); 

    if (resultado != null && resultado.files.isNotEmpty) {
      final archivo = resultado.files.first;
      if (archivo.bytes != null) {
        final exito = await ApiService.subirDocumento(
          archivo.bytes!,
          archivo.name,
          contratoId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(exito ? '✅ Documento subido correctamente' : '❌ Error al subir el documento'),
              backgroundColor: exito ? AppColors.esmeralda : Colors.red,
            ),
          );
        }
      }
    }
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
                                ElevatedButton.icon(
                                  onPressed: () => _subirDocumento(contratoId),
                                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                                  label: const Text(
                                    'Subir documento',
                                    style: TextStyle(
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