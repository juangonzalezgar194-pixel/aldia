import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';
import 'package:intl/intl.dart';

final NumberFormat _formatoMoneda = NumberFormat.decimalPattern('es_CO');

// Formatea un valor numérico (int, double o String) con separador
// de miles y el símbolo de peso. Ej: 800000 -> "$800.000"
String _formatearValorPago(dynamic valor) {
  if (valor == null) return '—';
  final numero = valor is num ? valor : num.tryParse('$valor');
  if (numero == null) return '—';
  return '\$${_formatoMoneda.format(numero)}';
}

class MisPagosScreen extends StatefulWidget {
  final int usuarioId;
  final bool esArrendador;

  const MisPagosScreen({
    super.key,
    required this.usuarioId,
    this.esArrendador = false,
  });

  @override
  State<MisPagosScreen> createState() => _MisPagosScreenState();
}

class _MisPagosScreenState extends State<MisPagosScreen> {
  List<dynamic> _pagos = [];
  bool _cargando = true;
  int? _contratoId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    setState(() => _cargando = true);

    final contratos = widget.esArrendador
        ? await ApiService.obtenerContratosPorArrendador(widget.usuarioId)
        : await ApiService.obtenerContratosPorArrendatario(widget.usuarioId);

    if (contratos == null || contratos.isEmpty) {
      setState(() {
        _pagos = [];
        _cargando = false;
        _error = 'No tienes un contrato registrado todavía';
      });
      return;
    }

    final contrato = contratos.firstWhere(
      (c) => c['estado'] == 'ACTIVO',
      orElse: () => contratos.first,
    );
    _contratoId = contrato['id'];

    final pagos = await ApiService.obtenerPagosPorContrato(_contratoId!);
    setState(() {
      _pagos = pagos ?? [];
      _cargando = false;
      _error = null;
    });
  }

  Future<void> _pagar(int pagoId) async {
    final exito = await ApiService.pagarPago(pagoId);
    if (!mounted) return;
    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pago realizado con éxito ✓'),
          backgroundColor: Colors.green,
        ),
      );
      _cargarPagos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo procesar el pago'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarPago(Map<String, dynamic> pago) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text(
          '¿Deseas marcar como pagado el periodo ${pago['periodo']}?\n\n'
          'Este es un pago simulado dentro del sistema, no se realiza ningún cobro real.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pagar(pago['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.esmeralda,
              // Evita heredar el minimumSize de ancho infinito del tema global:
              // dentro de las "actions" del AlertDialog el ancho no está acotado.
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // Muestra el comprobante de pago en un modal tipo "recibo".
  // Reutiliza los datos que ya vienen en el pago (folio, valor, fecha, etc.),
  // no requiere ninguna llamada adicional al backend.
  void _verComprobante(Map<String, dynamic> pago) {
    final folio = pago['folio'] ?? '—';
    final periodo = pago['periodo'] ?? '—';
    final fechaPago = pago['fechaPago'] ?? '—';
    final valor = pago['valorPagado'];
    final metodo = pago['metodoPago'] ?? '—';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.esmeralda.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: AppColors.esmeralda, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Comprobante de pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.azulPrincipal,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _filaComprobante('Folio', folio),
              _filaComprobante('Periodo', '$periodo'),
              _filaComprobante('Fecha de pago', '$fechaPago'),
              _filaComprobante('Valor', _formatearValorPago(valor)),
              _filaComprobante('Método', '$metodo'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.esmeralda.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.esmeralda, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Pago confirmado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.esmeralda,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaComprobante(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grisMedio,
              fontFamily: 'Nunito',
            ),
          ),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.azulPrincipal,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppColors.grisMedio, fontFamily: 'Nunito'),
        ),
      );
    }
    if (_pagos.isEmpty) {
      return _buildVacio();
    }
    return RefreshIndicator(
      onRefresh: _cargarPagos,
      child: _buildLista(),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.grisMedio.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No tienes pagos registrados',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.grisMedio,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pagos.length,
      itemBuilder: (context, index) {
        final pago = _pagos[index];
        final estado = pago['estado'] ?? 'PENDIENTE';
        final esPagado = estado == 'PAGADO';
        final esMora = estado == 'EN_MORA';

        final color = esPagado
            ? AppColors.esmeralda
            : esMora
                ? Colors.red
                : AppColors.naranja;

        final icono = esPagado
            ? Icons.check_circle_rounded
            : esMora
                ? Icons.error_rounded
                : Icons.schedule_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periodo: ${pago['periodo']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.azulPrincipal,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      'Fecha límite: ${pago['fechaLimite']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grisMedio,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      estado,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              // Si ya está pagado, ambos roles pueden ver el comprobante.
              if (esPagado)
                IconButton(
                  onPressed: () => _verComprobante(pago),
                  icon: const Icon(Icons.receipt_long_rounded),
                  color: AppColors.esmeralda,
                  tooltip: 'Ver comprobante',
                ),
              // Solo el arrendatario puede pagar; el arrendador es quien recibe
              // el dinero (simulado), así que para él este botón no debe mostrarse.
              if (!esPagado && !widget.esArrendador)
                ElevatedButton(
                  onPressed: () => _confirmarPago(pago),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.esmeralda,
                    // IMPORTANTE: el tema global (app_theme.dart) define un
                    // ElevatedButtonThemeData con minimumSize de ancho infinito
                    // (para botones como "Iniciar sesión"). Aquí el botón vive
                    // dentro de un Row sin Expanded, así que hay que anular ese
                    // ancho infinito o Flutter truena al hacer layout.
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Pagar',
                    style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}