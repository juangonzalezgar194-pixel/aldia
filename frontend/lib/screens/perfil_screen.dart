import 'package:flutter/material.dart';
import 'package:aldia/theme/app_theme.dart';
import 'package:aldia/screens/dashboard_screen.dart';
import 'package:aldia/services/api_service.dart';
import 'package:aldia/screens/login_screen.dart';
import 'package:aldia/screens/editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  final int usuarioId;
  final RolUsuario rol;

  const PerfilScreen({
    super.key,
    required this.usuarioId,
    required this.rol,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _usuario;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final usuario = await ApiService.obtenerUsuarioPorId(widget.usuarioId);
    setState(() {
      _usuario = usuario;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario?['nombre'] ?? 'Usuario';
    final correo = _usuario?['correo'] ?? '-';
    final telefono = _usuario?['telefono'] ?? '-';
    final rol = widget.rol == RolUsuario.arrendador ? 'Arrendador' : 'Arrendatario';

    return _cargando
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.azulPrincipal,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.azulPrincipal,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.esmeralda.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rol,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.esmeralda,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Datos personales
                _buildSeccion('Datos personales', [
                  _buildFila(Icons.person_rounded, 'Nombre', nombre),
                  _buildFila(Icons.mail_rounded, 'Correo', correo),
                  _buildFila(Icons.phone_rounded, 'Teléfono', telefono),
                ]),
                const SizedBox(height: 16),

                // Opciones
                _buildSeccion('Configuración', [
                  _buildOpcion(Icons.edit_rounded, 'Editar perfil', AppColors.azulPrincipal, () async {
                    final actualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditarPerfilScreen(
                          usuarioId: widget.usuarioId,
                          usuarioActual: _usuario ?? {},
                        ),
                      ),
                    );
                    if (actualizado != null) {
                      setState(() {
                        _usuario = actualizado;
                      });
                    }
                  }),
                  _buildOpcion(Icons.lock_rounded, 'Cambiar contraseña', AppColors.azulMedio, () {}),
                ]),
                const SizedBox(height: 16),

                // Cerrar sesión
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 22),
                        SizedBox(width: 14),
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSeccion(String titulo, List<Widget> items) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.grisMedio,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildFila(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.azulMedio),
          const SizedBox(width: 12),
          Text(
            '$etiqueta: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grisMedio,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.azulPrincipal,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcion(IconData icono, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icono, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColors.grisMedio, size: 20),
          ],
        ),
      ),
    );
  }
}