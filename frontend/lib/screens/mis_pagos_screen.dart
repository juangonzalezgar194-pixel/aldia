import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/services/api_service.dart';

class MisPagosScreen extends StatefulWidget {
  const MisPagosScreen({super.key});

  @override
  State<MisPagosScreen> createState() => _MisPagosScreenState();
}

class _MisPagosScreenState extends State<MisPagosScreen> {
  List<dynamic> _pagos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    final pagos = await ApiService.obtenerPagos();
    setState(() {
      _pagos = pagos ?? [];
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _cargando
            ? const Center(child: CircularProgressIndicator())
            : _pagos.isEmpty
                ? _buildVacio()
                : _buildLista(),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _mostrarRegistrarPago,
            backgroundColor: AppColors.esmeralda,
            icon: const Icon(Icons.add),
            label: const Text(
              'Registrar pago',
              style: TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
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
                  color: AppColors.esmeralda.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.esmeralda, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pago #${pago['id']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.azulPrincipal,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      '${pago['fechaPago'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grisMedio,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${pago['monto'] ?? '0'}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.azulPrincipal,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarRegistrarPago() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FormRegistrarPago(
        onPagoRegistrado: _cargarPagos,
      ),
    );
  }
}

class _FormRegistrarPago extends StatefulWidget {
  final VoidCallback onPagoRegistrado;
  const _FormRegistrarPago({required this.onPagoRegistrado});

  @override
  State<_FormRegistrarPago> createState() => _FormRegistrarPagoState();
}

class _FormRegistrarPagoState extends State<_FormRegistrarPago> {
  final _montoController = TextEditingController();
  bool _enviando = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrar pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.azulPrincipal,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _montoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto del pago',
              prefixIcon: Icon(Icons.attach_money_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _enviando ? null : _registrarPago,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.esmeralda,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _enviando
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Confirmar pago',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarPago() async {
    if (_montoController.text.isEmpty) return;
    setState(() => _enviando = true);

    final exito = await ApiService.registrarPago({
      'monto': double.tryParse(_montoController.text) ?? 0,
      'fechaPago': DateTime.now().toIso8601String(),
    });

    setState(() => _enviando = false);

    if (mounted) {
      Navigator.pop(context);
      if (exito) {
        widget.onPagoRegistrado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar el pago'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}