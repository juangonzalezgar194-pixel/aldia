import 'package:aldia/screens/contrato_screen.dart';
import 'package:aldia/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/widgets/aldia_logo.dart';
import 'package:aldia/screens/perfil_screen.dart';
import 'package:aldia/screens/contratos_screen.dart';
import 'package:aldia/screens/enviar_aviso_screen.dart';
import 'package:aldia/screens/comprobantes_screen.dart';
import 'package:aldia/screens/mi_contrato_screen.dart';
import 'package:aldia/widgets/banner_publicidad_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

enum RolUsuario { arrendador, arrendatario }

const List<String> _mesesNombres = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];

// ─────────────────────────────────────────────
// Calcula la próxima fecha de pago mensual a partir del día de pago
// del contrato (ej: diaPago = 5 -> próximo 5 del mes, este mes o el
// siguiente si ya pasó). Maneja correctamente el cambio de año.
// ─────────────────────────────────────────────
DateTime _proximaFechaPago(int diaPago) {
  final ahora = DateTime.now();
  final hoySinHora = DateTime(ahora.year, ahora.month, ahora.day);

  DateTime candidato = DateTime(ahora.year, ahora.month, diaPago);

  if (!candidato.isAfter(hoySinHora)) {
    candidato = DateTime(ahora.year, ahora.month + 1, diaPago);
  }
  return candidato;
}

String _formatearFecha(DateTime fecha) {
  return '${fecha.day} de ${_mesesNombres[fecha.month - 1]} de ${fecha.year}';
}

int _diasHasta(DateTime fecha) {
  final ahora = DateTime.now();
  final hoySinHora = DateTime(ahora.year, ahora.month, ahora.day);
  return fecha.difference(hoySinHora).inDays;
}

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
  bool _mostrarBannerPublicidad = true; // ← NUEVO: controla la visibilidad del banner

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
          return ContratosScreen(
            usuarioId: widget.usuarioId,
            nombreUsuario: widget.nombreUsuario,
          );
        case 2:
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
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(position: _slideAnim, child: _getBody()),
          ),
          // ← NUEVO: banner de publicidad flotante, se muestra 5s tras el login
          if (_mostrarBannerPublicidad)
            BannerPublicidadOverlay(
              onCerrar: () {
                setState(() {
                  _mostrarBannerPublicidad = false;
                });
              },
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.blanco,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const AlDiaLogo(size: 34, showText: true, compact: true),
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
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
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
// BANNER DE ENCABEZADO CON FOTO DE FONDO
// ─────────────────────────────────────────────
Widget _buildHeaderBanner(String nombre, String rol) {
  final ahora = DateTime.now();
  final diasSemana = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
  final fechaTexto = '${diasSemana[ahora.weekday - 1]}, ${ahora.day} de ${_mesesNombres[ahora.month - 1]} de ${ahora.year}';

  return ClipRRect(
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(32),
      bottomRight: Radius.circular(32),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 188,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/login_background.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x991A3A5C),
                  Color(0xE60B1B2B),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $nombre! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rol,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fechaTexto,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
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

  // ── NUEVO: selector/acceso rápido a comprobantes ──────────────
  void _mostrarSelectorComprobantes(BuildContext context) {
    if (_contratos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todavía no tienes contratos registrados.')),
      );
      return;
    }

    if (_contratos.length == 1) {
      _irAComprobantes(context, _contratos.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                'Elige un contrato',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.azulPrincipal,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 16),
              ..._contratos.map((contrato) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _irAComprobantes(context, contrato);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grisClaro,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.home_work_rounded,
                              color: AppColors.azulPrincipal, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Inmueble #${contrato['inmuebleId']} · Contrato #${contrato['id']}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.azulPrincipal,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.grisMedio),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _irAComprobantes(BuildContext context, dynamic contrato) {
    final contratoId = contrato['id'];
    final valorMensual = (contrato['valorMensual'] as num?)?.toDouble();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComprobantesScreen(
          contratoId: contratoId,
          usuarioActual: widget.nombreUsuario,
          esArrendador: true,
          valorMensual: valorMensual,
        ),
      ),
    );
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(widget.nombreUsuario, 'Arrendador'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
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
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _AccionRapida(icono: Icons.add_home_rounded, label: 'Nuevo\ninmueble', color: AppColors.azulPrincipal, onTap: () => _mostrarFormularioInmueble(context)),
                    _AccionRapida(icono: Icons.person_add_alt_1_rounded, label: 'Agregar\ninquilino', color: AppColors.esmeralda, onTap: () => _mostrarFormularioInquilino(context)),
                    _AccionRapida(icono: Icons.notifications_active_rounded, label: 'Enviar\navisos', color: AppColors.naranja, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnviarAvisoScreen()))),
                    _AccionRapida(icono: Icons.description_rounded,
                    label: 'Generar\ncontrato',
                    color: AppColors.azulMedio,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContratoScreen(
                    usuarioId: widget.usuarioId,
                    nombreUsuario: widget.nombreUsuario,
                    ))),
                    ),
                    _AccionRapida(
                      icono: Icons.receipt_long_rounded,
                      label: 'Ver\ncomprobantes',
                      color: AppColors.esmeralda,
                      onTap: () => _mostrarSelectorComprobantes(context),
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
                              final diaPago = contrato['diaPago'] is int
                                  ? contrato['diaPago'] as int
                                  : int.tryParse('${contrato['diaPago']}') ?? 1;
                              final proximaFecha = _proximaFechaPago(diaPago);
                              final dias = _diasHasta(proximaFecha);
                              final color = dias <= 5 ? AppColors.naranja : AppColors.esmeralda;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _TarjetaVencimiento(
                                  inquilino: 'Arrendatario #${contrato['arrendatarioId']}',
                                  inmueble: 'Inmueble #${contrato['inmuebleId']}',
                                  fechaVencimiento: _formatearFecha(proximaFecha),
                                  estado: '$dias días restantes',
                                  colorEstado: color,
                                ),
                              );
                            }).toList(),
                          ),
                const SizedBox(height: 24),
              ],
            ),
          ),
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
  bool _cargandoArrendador = false;

  @override
  void initState() {
    super.initState();
    _cargarContratos();
  }

  Future<void> _cargarContratos() async {
    final contratos = await ApiService.obtenerContratosPorArrendatario(widget.usuarioId);
    setState(() {
      _contratos = contratos ?? [];
    });
  }

  // ── CONTACTAR ARRENDADOR ──────────────────────────────
  Future<void> _contactarArrendador(BuildContext context) async {
    if (_contratos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todavía no tienes un contrato asignado.')),
      );
      return;
    }

    final arrendadorId = _contratos.first['arrendadorId'];
    if (arrendadorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el arrendador de tu contrato.')),
      );
      return;
    }

    setState(() => _cargandoArrendador = true);
    final arrendador = await ApiService.obtenerUsuarioPorId(
      arrendadorId is int ? arrendadorId : int.tryParse('$arrendadorId') ?? 0,
    );
    setState(() => _cargandoArrendador = false);

    if (arrendador == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la información del arrendador.')),
      );
      return;
    }

    if (!context.mounted) return;
    _mostrarOpcionesContacto(context, arrendador);
  }

  void _mostrarOpcionesContacto(BuildContext context, Map<String, dynamic> arrendador) {
    final nombre = '${arrendador['nombre'] ?? ''} ${arrendador['apellido'] ?? ''}'.trim();
    final telefono = (arrendador['telefono'] ?? '').toString().trim();
    final correo = (arrendador['correo'] ?? '').toString().trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    decoration: BoxDecoration(color: AppColors.naranja.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.naranja, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contactar arrendador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
                        if (nombre.isNotEmpty)
                          Text(nombre, style: const TextStyle(fontSize: 13, color: AppColors.grisMedio, fontFamily: 'Nunito')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (telefono.isNotEmpty) ...[
                _OpcionContacto(
                  icono: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  titulo: 'WhatsApp',
                  subtitulo: telefono,
                  onTap: () {
                    Navigator.pop(context);
                    _abrirWhatsApp(context, telefono);
                  },
                ),
                const SizedBox(height: 10),
                _OpcionContacto(
                  icono: Icons.phone_rounded,
                  color: AppColors.esmeralda,
                  titulo: 'Llamar',
                  subtitulo: telefono,
                  onTap: () {
                    Navigator.pop(context);
                    _abrirLlamada(context, telefono);
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (correo.isNotEmpty)
                _OpcionContacto(
                  icono: Icons.email_rounded,
                  color: AppColors.azulPrincipal,
                  titulo: 'Correo',
                  subtitulo: correo,
                  onTap: () {
                    Navigator.pop(context);
                    _abrirCorreo(context, correo, nombre);
                  },
                ),
              if (telefono.isEmpty && correo.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'El arrendador no tiene datos de contacto registrados.',
                    style: TextStyle(color: AppColors.grisMedio, fontFamily: 'Nunito'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrirWhatsApp(BuildContext context, String telefono) async {
    final numeroLimpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    // Si el número no incluye código de país, se asume Colombia (+57)
    final numeroConCodigo = numeroLimpio.startsWith('57') ? numeroLimpio : '57$numeroLimpio';
    final uri = Uri.parse('https://wa.me/$numeroConCodigo');
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp.')),
      );
    }
  }

  Future<void> _abrirLlamada(BuildContext context, String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    final abierto = await launchUrl(uri);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la llamada.')),
      );
    }
  }

  Future<void> _abrirCorreo(BuildContext context, String correo, String nombre) async {
    final uri = Uri(
      scheme: 'mailto',
      path: correo,
      query: 'subject=${Uri.encodeComponent('Contacto desde AlDía')}',
    );
    final abierto = await launchUrl(uri);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la app de correo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(widget.nombreUsuario, 'Arrendatario'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSeccionTitulo('Acciones rápidas'),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AccionRapida(
                      icono: Icons.description_rounded,
                      label: 'Mi\ncontrato',
                      color: AppColors.azulMedio,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MiContratoScreen(usuarioId: widget.usuarioId),
                        ),
                      ),
                    ),
                    _AccionRapida(
                      icono: Icons.support_agent_rounded,
                      label: 'Contactar\narrendador',
                      color: AppColors.naranja,
                      onTap: () {
                        if (_cargandoArrendador) return;
                        _contactarArrendador(context);
                      },
                    ),
                    _AccionRapida(
                      icono: Icons.receipt_long_rounded,
                      label: 'Comprobantes',
                      color: AppColors.esmeralda,
                      onTap: () {
                        if (_contratos.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Todavía no tienes un contrato asignado.')),
                          );
                          return;
                        }
                        final contrato = _contratos.first;
                        final contratoId = contrato['id'];
                        final valorMensual = (contrato['valorMensual'] as num?)?.toDouble();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ComprobantesScreen(
                              contratoId: contratoId,
                              usuarioActual: widget.nombreUsuario,
                              esArrendador: false,
                              valorMensual: valorMensual,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGETS COMPARTIDOS
// ─────────────────────────────────────────────

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

class _AccionRapida extends StatefulWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccionRapida({required this.icono, required this.label, required this.color, required this.onTap});

  @override
  State<_AccionRapida> createState() => _AccionRapidaState();
}

class _AccionRapidaState extends State<_AccionRapida> {
  bool _hovering = false;
  bool _presionado = false;

  bool get _activo => _hovering || _presionado;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _presionado = true),
        onTapCancel: () => setState(() => _presionado = false),
        onTapUp: (_) => setState(() => _presionado = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _activo ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _activo ? widget.color : widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _activo
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  widget.icono,
                  color: _activo ? Colors.white : widget.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.azulPrincipal, fontFamily: 'Nunito', height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionContacto extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionContacto({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.grisClaro,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.azulPrincipal, fontFamily: 'Nunito')),
                  Text(subtitulo, style: const TextStyle(fontSize: 12, color: AppColors.grisMedio, fontFamily: 'Nunito')),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grisMedio),
          ],
        ),
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