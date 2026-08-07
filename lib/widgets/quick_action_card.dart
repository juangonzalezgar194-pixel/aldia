import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Paleta de AlDía — ajusta estos valores si tus colores exactos son otros.
class AlDiaColors {
  static const navy = Color(0xFF1B2A4A);
  static const teal = Color(0xFF1BA98C);
  static const orange = Color(0xFFF2994A);
  static const background = Color(0xFFF5F7FA);
}

/// Tarjeta de acción rápida reutilizable (Mi contrato, Contactar arrendador,
/// Comprobantes, y cualquier otra que agreguen a futuro).
///
/// Uso:
/// ```dart
/// QuickActionCard(
///   icon: Icons.description_outlined,
///   title: 'Mi contrato',
///   subtitle: 'Ver estado y detalles',
///   accentColor: AlDiaColors.navy,
///   onTap: () => Navigator.pushNamed(context, '/mi-contrato'),
/// )
/// ```
class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _isActive => _hovering || _pressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isActive ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isActive
                    ? AlDiaColors.orange
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isActive
                      ? AlDiaColors.navy.withOpacity(0.18)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: _isActive ? 24 : 12,
                  offset: Offset(0, _isActive ? 10 : 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isActive
                        ? widget.accentColor
                        : widget.accentColor.withOpacity(0.12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 30,
                    color: _isActive ? Colors.white : widget.accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AlDiaColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sección "Acciones rápidas" con grid responsive.
/// Cambia el número de columnas según el ancho disponible.
class QuickActionsSection extends StatelessWidget {
  final List<QuickActionCard> actions;

  const QuickActionsSection({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 3;
        if (width < 500) {
          columns = 1;
        } else if (width < 850) {
          columns = 2;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: AlDiaColors.teal, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AlDiaColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.1,
              children: actions,
            ),
          ],
        );
      },
    );
  }
}