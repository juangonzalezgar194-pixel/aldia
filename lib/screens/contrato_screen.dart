import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MilesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Solo dígitos, sin puntos ni comas
    String soloDigitos = newValue.text.replaceAll('.', '').replaceAll(',', '');
    if (soloDigitos.isEmpty) return newValue.copyWith(text: '');

    final numero = int.tryParse(soloDigitos);
    if (numero == null) return oldValue;

    final formateado = _formatearMiles(numero);

    return TextEditingValue(
      text: formateado,
      selection: TextSelection.collapsed(offset: formateado.length),
    );
  }

  String _formatearMiles(int numero) {
    final texto = numero.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(texto[i]);
    }
    return buffer.toString();
  }
}

class ContratoScreen extends StatefulWidget {
  final int usuarioId; // ID del arrendador logueado
  final String nombreUsuario; // Nombre del arrendador logueado

  const ContratoScreen({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
  });

  @override
  State<ContratoScreen> createState() => _ContratoScreenState();
}

class _ContratoScreenState extends State<ContratoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Datos del arrendatario (ya no se selecciona de una lista, se escribe directo)
  final _arrendatarioNombreController = TextEditingController();
  final _arrendatarioApellidoController = TextEditingController();
  final _arrendatarioDocumentoController = TextEditingController();
  final _arrendatarioCorreoController = TextEditingController();
  final _arrendatarioTelefonoController = TextEditingController();

  final _valorController = TextEditingController();
  final _diaController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _observacionesController = TextEditingController();

  bool _generando = false;
  bool _cargandoDatos = true;

  List<dynamic> _inmuebles = [];

  dynamic _inmuebleSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Solo trae inmuebles del propietario que actualmente estén disponibles
    // (activos y sin contrato vigente). Una vez un inmueble queda arrendado,
    // el backend deja de devolverlo aquí.
    final inmuebles =
        await ApiService.obtenerInmueblesDisponiblesPorPropietario(widget.usuarioId);
    if (!mounted) return;
    setState(() {
      _inmuebles = inmuebles ?? [];
      _cargandoDatos = false;
    });
  }

  @override
  void dispose() {
    _arrendatarioNombreController.dispose();
    _arrendatarioApellidoController.dispose();
    _arrendatarioDocumentoController.dispose();
    _arrendatarioCorreoController.dispose();
    _arrendatarioTelefonoController.dispose();
    _valorController.dispose();
    _diaController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (fecha != null) {
      controller.text =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _generarPDF() async {
    if (!_formKey.currentState!.validate()) return;

    if (_inmuebleSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el inmueble')),
      );
      return;
    }

    setState(() => _generando = true);

    final valor = double.tryParse(_valorController.text.replaceAll(',', '').replaceAll('.', '')) ?? 0;
    final dia = int.tryParse(_diaController.text) ?? 1;

    final payload = <String, dynamic>{
      'arrendatarioNombre': _arrendatarioNombreController.text.trim(),
      'arrendatarioApellido': _arrendatarioApellidoController.text.trim(),
      'arrendatarioNumDocumento': _arrendatarioDocumentoController.text.trim(),
      'arrendatarioCorreo': _arrendatarioCorreoController.text.trim(),
      'arrendatarioTelefono': _arrendatarioTelefonoController.text.trim(),
      'inmuebleId': _inmuebleSeleccionado['id'],
      'arrendadorId': widget.usuarioId,
      'valorMensual': valor,
      'diaPago': dia,
      'fechaInicio': _fechaInicioController.text,
      if (_fechaFinController.text.isNotEmpty) 'fechaFin': _fechaFinController.text,
      if (_observacionesController.text.isNotEmpty) 'observaciones': _observacionesController.text,
    };

    // 1) Primero registramos el contrato en el backend.
    // La respuesta ahora viene envuelta: { contrato, arrendatarioNuevo, arrendatarioId, correoActivacionEnviado }
    // Si el inmueble ya no está disponible (otro contrato lo tomó mientras
    // llenabas el formulario), el backend responde 409 y crearContrato devuelve null.
    final resultado = await ApiService.crearContrato(payload);

    if (resultado == null || resultado['contrato'] == null) {
      setState(() => _generando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo registrar el contrato. El inmueble podría ya no estar disponible, o hubo un error de conexión.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool arrendatarioNuevo = resultado['arrendatarioNuevo'] ?? false;
    final bool correoEnviado = resultado['correoActivacionEnviado'] ?? false;

    // 2) Solo si el backend confirmó, generamos el PDF local para mostrar/imprimir
    final nombreArrendatario =
        '${_arrendatarioNombreController.text.trim()} ${_arrendatarioApellidoController.text.trim()}'.trim();
    final direccionInmueble = _inmuebleSeleccionado['direccion'] ?? '';

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
            _filaPDF('Arrendador', widget.nombreUsuario),
            _filaPDF('Arrendatario', nombreArrendatario),
            pw.Divider(height: 30),
            pw.Text(
              'Detalles del inmueble y contrato:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _filaPDF('Inmueble / Dirección', direccionInmueble),
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
                      widget.nombreUsuario,
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
                      nombreArrendatario,
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

    if (!mounted) return;

    // Mensaje de confirmación que refleja qué pasó realmente con el arrendatario
    String mensaje = 'Contrato registrado y PDF generado ✓';
    if (arrendatarioNuevo) {
      mensaje = correoEnviado
          ? 'Contrato creado. Se registró a $nombreArrendatario como nuevo arrendatario y se le envió su código de activación ✓'
          : 'Contrato creado. Se registró a $nombreArrendatario como nuevo arrendatario, pero no se pudo enviar el correo de activación (revisa la config. de Resend)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.esmeralda,
      ),
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
        child: _cargandoDatos
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Partes del contrato'),
                      const SizedBox(height: 16),
                      _labelCampo('Arrendador'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.grisClaro,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                color: AppColors.grisMedio, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              widget.nombreUsuario,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.azulPrincipal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _labelCampo('Nombre del arrendatario'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _arrendatarioNombreController,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Xiomara',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: AppColors.grisMedio, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _labelCampo('Apellido del arrendatario'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _arrendatarioApellidoController,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Roldán',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: AppColors.grisMedio, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _labelCampo('Número de documento'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _arrendatarioDocumentoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Ej: 1010101010',
                          prefixIcon: Icon(Icons.badge_outlined,
                              color: AppColors.grisMedio, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _labelCampo('Correo del arrendatario'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _arrendatarioCorreoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded,
                              color: AppColors.grisMedio, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Campo requerido';
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _labelCampo('Teléfono del arrendatario'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _arrendatarioTelefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Ej: 3001234567',
                          prefixIcon: Icon(Icons.phone_outlined,
                              color: AppColors.grisMedio, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 28),
                      _sectionTitle('Detalles del inmueble'),
                      const SizedBox(height: 16),
                      _labelCampo('Inmueble'),
                      const SizedBox(height: 8),
                      _inmuebles.isEmpty
                          ? _mensajeVacio('No tienes inmuebles disponibles para arrendar en este momento')
                          : DropdownButtonFormField<dynamic>(
                              initialValue: _inmuebleSeleccionado,
                              decoration: const InputDecoration(
                                hintText: 'Selecciona el inmueble',
                                prefixIcon: Icon(Icons.home_outlined,
                                    color: AppColors.grisMedio, size: 20),
                              ),
                              items: _inmuebles.map((inm) {
                                final direccion = inm['direccion'] ?? '';
                                final ciudad = inm['ciudad'] ?? '';
                                return DropdownMenuItem(
                                  value: inm,
                                  child: Text(
                                    '$direccion - $ciudad',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _inmuebleSeleccionado = v),
                              validator: (v) => v == null ? 'Selecciona un inmueble' : null,
                            ),
                      const SizedBox(height: 16),
                      _labelCampo('Valor mensual'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _valorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          MilesFormatter(),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Ej: 800.000',
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
                        readOnly: true,
                        onTap: () => _seleccionarFecha(_fechaInicioController),
                        decoration: const InputDecoration(
                          hintText: 'Selecciona la fecha',
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
                        readOnly: true,
                        onTap: () => _seleccionarFecha(_fechaFinController),
                        decoration: const InputDecoration(
                          hintText: 'Selecciona la fecha o deja vacío',
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

  Widget _mensajeVacio(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.grisClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          color: AppColors.grisMedio,
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