import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ContratoScreen extends StatefulWidget {
  const ContratoScreen({super.key});

  @override
  State<ContratoScreen> createState() => _ContratoScreenState();
}

class _ContratoScreenState extends State<ContratoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arrendadorController = TextEditingController();
  final _arrendatarioController = TextEditingController();
  final _inmuebleController = TextEditingController();
  final _valorController = TextEditingController();
  final _diaController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _observacionesController = TextEditingController();
  bool _generando = false;

  @override
  void dispose() {
    _arrendadorController.dispose();
    _arrendatarioController.dispose();
    _inmuebleController.dispose();
    _valorController.dispose();
    _diaController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _generarPDF() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _generando = true);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'CONTRATO DE ARRENDAMIENTO',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'AlDía – Sistema de Gestión de Arriendos',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
            pw.Divider(height: 30),
            pw.Text(
              'Entre las partes:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _filaPDF('Arrendador', _arrendadorController.text),
            _filaPDF('Arrendatario', _arrendatarioController.text),
            pw.Divider(height: 30),
            pw.Text(
              'Detalles del inmueble y contrato:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _filaPDF('Inmueble / Dirección', _inmuebleController.text),
            _filaPDF('Valor mensual', '\$${_valorController.text}'),
            _filaPDF('Día de pago', _diaController.text),
            _filaPDF('Fecha de inicio', _fechaInicioController.text),
            _filaPDF('Fecha de fin', _fechaFinController.text.isEmpty ? 'Indefinido' : _fechaFinController.text),
            pw.Divider(height: 30),
            pw.Text(
              'Cláusulas:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '1. El arrendatario se compromete a pagar el valor mensual acordado antes o en el día de pago estipulado.',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '2. El arrendador se compromete a mantener el inmueble en condiciones habitables durante la vigencia del contrato.',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '3. Cualquier modificación al presente contrato deberá ser acordada por escrito entre ambas partes.',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '4. Este contrato se rige por las leyes colombianas vigentes en materia de arrendamiento (Ley 820 de 2003).',
              style: const pw.TextStyle(fontSize: 11),
            ),
            if (_observacionesController.text.isNotEmpty) ...[
              pw.Divider(height: 30),
              pw.Text(
                'Observaciones:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                _observacionesController.text,
                style: const pw.TextStyle(fontSize: 11),
              ),
            ],
            pw.Divider(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('_______________________'),
                    pw.SizedBox(height: 4),
                    pw.Text('Arrendador'),
                    pw.Text(
                      _arrendadorController.text,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('_______________________'),
                    pw.SizedBox(height: 4),
                    pw.Text('Arrendatario'),
                    pw.Text(
                      _arrendatarioController.text,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                'Generado por AlDía – ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );

    setState(() => _generando = false);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  pw.Widget _filaPDF(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: AppBar(
        backgroundColor: AppColors.blanco,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.azulPrincipal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Generar Contrato',
          style: TextStyle(
            color: AppColors.azulPrincipal,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Partes del contrato'),
                const SizedBox(height: 16),
                _labelCampo('Nombre del arrendador'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _arrendadorController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre completo del arrendador',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: AppColors.grisMedio, size: 20),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                _labelCampo('Nombre del arrendatario'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _arrendatarioController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre completo del arrendatario',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: AppColors.grisMedio, size: 20),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 28),
                _sectionTitle('Detalles del inmueble'),
                const SizedBox(height: 16),
                _labelCampo('Dirección del inmueble'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _inmuebleController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Calle 10 # 5-23, Fusagasugá',
                    prefixIcon: Icon(Icons.home_outlined,
                        color: AppColors.grisMedio, size: 20),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                _labelCampo('Valor mensual'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ej: 800000',
                    prefixIcon: Icon(Icons.attach_money_rounded,
                        color: AppColors.grisMedio, size: 20),
                    prefixText: '\$ ',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                _labelCampo('Día de pago mensual'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _diaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ej: 5',
                    prefixIcon: Icon(Icons.calendar_today_outlined,
                        color: AppColors.grisMedio, size: 20),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                _labelCampo('Fecha de inicio'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fechaInicioController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: 2026-07-01',
                    prefixIcon: Icon(Icons.date_range_outlined,
                        color: AppColors.grisMedio, size: 20),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                _labelCampo('Fecha de fin (opcional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fechaFinController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: 2027-07-01 o dejar vacío',
                    prefixIcon: Icon(Icons.date_range_outlined,
                        color: AppColors.grisMedio, size: 20),
                  ),
                ),
                const SizedBox(height: 28),
                _sectionTitle('Observaciones'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Observaciones adicionales (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _generando ? null : _generarPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulPrincipal,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _generando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded,
                          color: Colors.white),
                  label: Text(
                    _generando ? 'Generando...' : 'Generar contrato PDF',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.naranja,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.azulPrincipal,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }

  Widget _labelCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.azulPrincipal,
        fontFamily: 'Nunito',
      ),
    );
  }
}