import 'package:aldia/screens/mis_pagos_screen.dart';
import 'package:aldia/screens/contrato_screen.dart';
import 'package:aldia/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/widgets/aldia_logo.dart';
import 'package:aldia/screens/perfil_screen.dart';
import 'package:aldia/screens/contratos_screen.dart';
import 'package:aldia/screens/enviar_aviso_screen.dart';

enum RolUsuario { arrendador, arrendatario }

class DashboardScreen extends StatefulWidget {
  final RolUsuario rol;
  final String nombreUsuario;
  final int usuarioId;

  const DashboardScreen({
    super.key,
    required this.rol,
    required this.nombreUsuario,
    required this.usuarioId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _getBody() {
    final esArrendador = widget.rol == RolUsuario.arrendador;
    if (esArrendador) {
      switch (_selectedIndex) {
        case 0:
          return _DashboardArrendador(
            nombreUsuario: widget.nombreUsuario,
            usuarioId: widget.usuarioId,
          );
        case 1:
          return ContratosScreen(usuarioId: widget.usuarioId);
        case 2:
          return const MisPagosScreen();
        case 3:
          return PerfilScreen(usuarioId: widget.usuarioId, rol: widget.rol);
        default:
          return _DashboardArrendador(
            nombreUsuario: widget.nombreUsuario,
            usuarioId: widget.usuarioId,
          );
      }
    } else {
      switch (_selectedIndex) {
        case 0:
          return _DashboardArrendatario(
            nombreUsuario: widget.nombreUsuario,
            usuarioId: widget.usuarioId,
          );
        case 1:
          return const MisPagosScreen();
        case 2:
          return const Center(child: Text('Historial - Próximamente'));
        case 3:
          return PerfilScreen(usuarioId: widget.usuarioId, rol: widget.rol);
        default:
          return _DashboardArrendatario(
            nombreUsuario: widget.nombreUsuario,
            usuarioId: widget.usuarioId,
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esArrendador = widget.rol == RolUsuario.arrendador;
    return Scaffold(
      backgroundColor: AppColors.grisClaro,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(esArrendador),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(position: _slideAnim, child: _getBody()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.blanco,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const AlDiaLogo(size: 32, showText: true),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.azulPrincipal),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.azulPrincipal,
              child: Text(
                widget.nombreUsuario.isNotEmpty ? widget.nombreUsuario[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.blanco,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(bool esArrendador) {
    final items = esArrendador
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.home_work_outlined), activeIcon: Icon(Icons.home_work_rounded), label: 'Contratos'),
            BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments_rounded), label: 'Pagos'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'Mis Pagos'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history_rounded), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
          ];

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.blanco,
      selectedItemColor: AppColors.esmeralda,
      unselectedItemColor: AppColors.grisMedio,
      selectedLabelStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 11),
      elevation: 12,
      items: items,
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD ARRENDADOR
// ─────────────────────────────────────────────
class _DashboardArrendador extends StatefulWidget {
  final String nombreUsuario;
  final int usuarioId;

  const _DashboardArrendador({required this.nombreUsuario, required this.usuarioId});

  @override
  State<_DashboardArrendador> createState() => _DashboardArrendadorState();
}

class _DashboardArrendadorState extends State<_DashboardArrendador> {
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

  int _calcularDias(String? fechaFin) {
    if (fechaFin == null) return 9999;
    final fecha = DateTime.parse(fechaFin);
    return fecha.difference(DateTime.now()).inDays;
  }

  // ── BOTTOM SHEET NUEVO INMUEBLE ──────────────────────────────
  void _mostrarFormularioInmueble(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final direccionCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    final inquilinoCtrl = TextEditingController();
    final fechaInicioCtrl = TextEditingController();
    bool guardando = false;

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
                left: 24, right: 24, top: 24,
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
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: const Color(0xFFDDE3EC), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(color: AppColors.azulPrincipal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_home_rounded, color: AppColors.azulPrincipal, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text('Nuevo inmueble', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _campoFormulario(controlador: direccionCtrl, etiqueta: 'Dirección del inmueble', icono: Icons.location_on_rounded, validar: (v) => v!.isEmpty ? 'Ingresa la dirección' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: descripcionCtrl, etiqueta: 'Descripción (ej: Apto 201, casa, local)', icono: Icons.home_work_outlined, validar: (v) => v!.isEmpty ? 'Ingresa una descripción' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: valorCtrl, etiqueta: 'Valor del arriendo', icono: Icons.attach_money_rounded, teclado: TextInputType.number, validar: (v) => v!.isEmpty ? 'Ingresa el valor' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: inquilinoCtrl, etiqueta: 'Nombre del arrendatario', icono: Icons.person_add_alt_1_rounded, validar: (v) => v!.isEmpty ? 'Ingresa el nombre' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(
                        controlador: fechaInicioCtrl,
                        etiqueta: 'Fecha inicio del contrato',
                        icono: Icons.calendar_today_rounded,
                        soloLectura: true,
                        validar: (v) => v!.isEmpty ? 'Selecciona la fecha' : null,
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (fecha != null) {
                            fechaInicioCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: guardando ? null : () async {
                            if (formKey.currentState!.validate()) {
                              setModalState(() => guardando = true);
                              await Future.delayed(const Duration(seconds: 1));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inmueble registrado ✓'), backgroundColor: AppColors.esmeralda),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azulPrincipal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: guardando
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('Guardar inmueble', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15)),
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

  // ── BOTTOM SHEET AGREGAR INQUILINO ──────────────────────────────
  void _mostrarFormularioInquilino(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final inmuebleCtrl = TextEditingController();
    bool guardando = false;

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
                left: 24, right: 24, top: 24,
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
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: const Color(0xFFDDE3EC), borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(color: AppColors.esmeralda.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.esmeralda, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text('Agregar inquilino', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _campoFormulario(controlador: nombreCtrl, etiqueta: 'Nombre completo', icono: Icons.person_rounded, validar: (v) => v!.isEmpty ? 'Ingresa el nombre' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: cedulaCtrl, etiqueta: 'Número de cédula', icono: Icons.badge_rounded, teclado: TextInputType.number, validar: (v) => v!.isEmpty ? 'Ingresa la cédula' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: telefonoCtrl, etiqueta: 'Teléfono', icono: Icons.phone_rounded, teclado: TextInputType.phone, validar: (v) => v!.isEmpty ? 'Ingresa el teléfono' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: correoCtrl, etiqueta: 'Correo electrónico', icono: Icons.email_rounded, teclado: TextInputType.emailAddress, validar: (v) => v!.isEmpty ? 'Ingresa el correo' : null),
                      const SizedBox(height: 14),
                      _campoFormulario(controlador: inmuebleCtrl, etiqueta: 'Inmueble asignado (ej: Apto 201)', icono: Icons.home_work_rounded, validar: (v) => v!.isEmpty ? 'Ingresa el inmueble' : null),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: guardando ? null : () async {
                            if (formKey.currentState!.validate()) {
                              setModalState(() => guardando = true);
                              await Future.delayed(const Duration(seconds: 1));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inquilino agregado ✓'), backgroundColor: AppColors.esmeralda),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.esmeralda,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: guardando
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('Guardar inquilino', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15)),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSaludo(widget.nombreUsuario, 'Arrendador'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _TarjetaResumen(icono: Icons.home_work_rounded, titulo: 'Contratos', valor: '${_contratos.length}', color: AppColors.azulPrincipal)),
              const SizedBox(width: 12),
              Expanded(child: _TarjetaResumen(icono: Icons.check_circle_rounded, titulo: 'Activos', valor: '${_contratos.where((c) => c['estado'] == 'ACTIVO').length}', color: AppColors.esmeralda)),
            ],
          ),
          const SizedBox(height: 28),
          _buildSeccionTitulo('Acciones rápidas'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AccionRapida(icono: Icons.add_home_rounded, label: 'Nuevo\ninmueble', color: AppColors.azulPrincipal, onTap: () => _mostrarFormularioInmueble(context)),
            _AccionRapida(icono: Icons.person_add_alt_1_rounded, label: 'Agregar\ninquilino', color: AppColors.esmeralda, onTap: () => _mostrarFormularioInquilino(context)),
            _AccionRapida(icono: Icons.notifications_active_rounded, label: 'Enviar\navisos', color: AppColors.naranja, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnviarAvisoScreen()))),
            _AccionRapida(icono: Icons.description_rounded,
            label: 'Generar\ncontrato',
            color: AppColors.azulMedio,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContratoScreen())),
            ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSeccionTitulo('Próximos vencimientos'),
          const SizedBox(height: 14),
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : _contratos.isEmpty
                  ? const Center(child: Text('No hay contratos registrados', style: TextStyle(color: AppColors.grisMedio, fontFamily: 'Nunito')))
                  : Column(
                      children: _contratos.map((contrato) {
                        final dias = _calcularDias(contrato['fechaFin']);
                        final estado = contrato['estado'] ?? 'ACTIVO';
                        final color = dias <= 30 ? AppColors.naranja : AppColors.esmeralda;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TarjetaVencimiento(
                            inquilino: 'Arrendatario #${contrato['arrendatarioId']}',
                            inmueble: 'Inmueble #${contrato['inmuebleId']}',
                            fechaVencimiento: contrato['fechaFin'] ?? 'Indefinido',
                            estado: dias == 9999 ? estado : '$dias días restantes',
                            colorEstado: color,
                          ),
                        );
                      }).toList(),
                    ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD ARRENDATARIO
// ─────────────────────────────────────────────
class _DashboardArrendatario extends StatefulWidget {
  final String nombreUsuario;
  final int usuarioId;

  const _DashboardArrendatario({required this.nombreUsuario, required this.usuarioId});

  @override
  State<_DashboardArrendatario> createState() => _DashboardArrendatarioState();
}

class _DashboardArrendatarioState extends State<_DashboardArrendatario> {
  List<dynamic> _contratos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarContratos();
  }

  Future<void> _cargarContratos() async {
    final contratos = await ApiService.obtenerContratosPorArrendatario(widget.usuarioId);
    setState(() {
      _contratos = contratos ?? [];
      _cargando = false;
    });
  }

  int _calcularDias(String? fechaFin) {
    if (fechaFin == null) return 9999;
    final fecha = DateTime.parse(fechaFin);
    return fecha.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final contrato = _contratos.isNotEmpty ? _contratos.first : null;
    final dias = contrato != null ? _calcularDias(contrato['fechaFin']) : 0;
    final valor = contrato != null ? '\$${contrato['valorMensual']}' : '\$0';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSaludo(widget.nombreUsuario, 'Arrendatario'),
          const SizedBox(height: 24),
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : contrato == null
                  ? const Center(child: Text('No tienes contratos activos', style: TextStyle(color: AppColors.grisMedio, fontFamily: 'Nunito')))
                  : _TarjetaEstadoPago(
                      fechaVencimiento: contrato['fechaFin'] ?? 'Indefinido',
                      valorArriendo: valor,
                      diasRestantes: dias == 9999 ? 999 : dias,
                    ),
          const SizedBox(height: 24),
          _buildSeccionTitulo('Acciones rápidas'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AccionRapida(icono: Icons.payment_rounded, label: 'Registrar\npago', color: AppColors.esmeralda, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MisPagosScreen()))),
              _AccionRapida(icono: Icons.history_rounded, label: 'Ver\nhistorial', color: AppColors.azulPrincipal, onTap: () {}),
              _AccionRapida(icono: Icons.description_rounded, label: 'Mi\ncontrato', color: AppColors.azulMedio, onTap: () {}),
              _AccionRapida(icono: Icons.support_agent_rounded, label: 'Contactar\narrendador', color: AppColors.naranja, onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS COMPARTIDOS
// ─────────────────────────────────────────────

Widget _buildSaludo(String nombre, String rol) {
  final ahora = DateTime.now();
  final diasSemana = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
  final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
  final fechaTexto = '${diasSemana[ahora.weekday - 1]}, ${ahora.day} de ${meses[ahora.month - 1]} de ${ahora.year}';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('¡Hola, $nombre! 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      Text(rol, style: const TextStyle(fontSize: 13, color: AppColors.grisMedio, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(fechaTexto, style: const TextStyle(fontSize: 12, color: AppColors.esmeralda, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
    ],
  );
}

Widget _buildSeccionTitulo(String titulo) {
  return Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.azulPrincipal, fontFamily: 'Nunito'));
}

Widget _campoFormulario({
  required TextEditingController controlador,
  required String etiqueta,
  required IconData icono,
  TextInputType teclado = TextInputType.text,
  String? Function(String?)? validar,
  bool soloLectura = false,
  VoidCallback? onTap,
}) {
  return TextFormField(
    controller: controlador,
    keyboardType: teclado,
    readOnly: soloLectura,
    onTap: onTap,
    validator: validar,
    style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
    decoration: InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.grisMedio),
      prefixIcon: Icon(icono, color: AppColors.azulPrincipal, size: 20),
      filled: true,
      fillColor: AppColors.grisClaro,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.azulPrincipal, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

// ─────────────────────────────────────────────
// COMPONENTES
// ─────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;

  const _TarjetaResumen({required this.icono, required this.titulo, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A1A3A5C), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito')),
              Text(titulo, style: const TextStyle(fontSize: 11, color: AppColors.grisMedio, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccionRapida extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccionRapida({required this.icono, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icono, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.azulPrincipal, fontFamily: 'Nunito', height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _TarjetaVencimiento extends StatelessWidget {
  final String inquilino;
  final String inmueble;
  final String fechaVencimiento;
  final String estado;
  final Color colorEstado;

  const _TarjetaVencimiento({required this.inquilino, required this.inmueble, required this.fechaVencimiento, required this.estado, required this.colorEstado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A1A3A5C), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.azulPrincipal.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_rounded, color: AppColors.azulPrincipal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inquilino, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
                const SizedBox(height: 2),
                Text(inmueble, style: const TextStyle(fontSize: 12, color: AppColors.grisMedio, fontFamily: 'Nunito')),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.grisMedio),
                    const SizedBox(width: 4),
                    Text('Vence: $fechaVencimiento', style: const TextStyle(fontSize: 11, color: AppColors.grisMedio, fontFamily: 'Nunito')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: colorEstado.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(estado, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorEstado, fontFamily: 'Nunito')),
          ),
        ],
      ),
    );
  }
}

class _TarjetaEstadoPago extends StatelessWidget {
  final String fechaVencimiento;
  final String valorArriendo;
  final int diasRestantes;

  const _TarjetaEstadoPago({required this.fechaVencimiento, required this.valorArriendo, required this.diasRestantes});

  @override
  Widget build(BuildContext context) {
    final urgente = diasRestantes <= 3;
    final color = urgente ? AppColors.naranja : AppColors.esmeralda;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.azulPrincipal, AppColors.azulMedio], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.azulPrincipal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estado de pago', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))),
                child: Text(urgente ? '¡Próximo a vencer!' : 'Al día ✓', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(valorArriendo, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, fontFamily: 'Nunito')),
          const SizedBox(height: 4),
          const Text('Arriendo mensual', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Nunito')),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text('Vence el $fechaVencimiento', style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$diasRestantes días restantes', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MisPagosScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.esmeralda,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Registrar pago', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _TarjetaContrato extends StatelessWidget {
  final String inmueble;
  final String direccion;
  final String arrendador;
  final String valorMensual;
  final String fechaInicio;
  final String fechaFin;

  const _TarjetaContrato({required this.inmueble, required this.direccion, required this.arrendador, required this.valorMensual, required this.fechaInicio, required this.fechaFin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A1A3A5C), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _filaDato(Icons.home_rounded, 'Inmueble', inmueble),
          const Divider(height: 20, color: AppColors.azulClaro),
          _filaDato(Icons.location_on_rounded, 'Dirección', direccion),
          const Divider(height: 20, color: AppColors.azulClaro),
          _filaDato(Icons.person_rounded, 'Arrendador', arrendador),
          const Divider(height: 20, color: AppColors.azulClaro),
          _filaDato(Icons.attach_money_rounded, 'Valor mensual', valorMensual),
          const Divider(height: 20, color: AppColors.azulClaro),
          _filaDato(Icons.date_range_rounded, 'Vigencia', '$fechaInicio → $fechaFin'),
        ],
      ),
    );
  }

  Widget _filaDato(IconData icono, String etiqueta, String valor) {
    return Row(
      children: [
        Icon(icono, size: 18, color: AppColors.azulMedio),
        const SizedBox(width: 10),
        Text('$etiqueta: ', style: const TextStyle(fontSize: 12, color: AppColors.grisMedio, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
        Expanded(child: Text(valor, style: const TextStyle(fontSize: 12, color: AppColors.azulPrincipal, fontFamily: 'Nunito', fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _ItemPago extends StatelessWidget {
  final String mes;
  final String valor;
  final String fecha;
  final String estado;

  const _ItemPago({required this.mes, required this.valor, required this.fecha, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0A1A3A5C), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: AppColors.esmeralda.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.esmeralda, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mes, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
                Text(fecha, style: const TextStyle(fontSize: 11, color: AppColors.grisMedio, fontFamily: 'Nunito')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
              Text(estado, style: const TextStyle(fontSize: 11, color: AppColors.esmeralda, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
            ],
          ),
        ],
      ),
    );
  }
}