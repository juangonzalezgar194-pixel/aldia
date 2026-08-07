import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:aldia/theme/app_theme.dart';

class AlDiaLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final bool compact;

  /// Si es true, los rayos del sol se encienden en secuencia en loop,
  /// como efecto de "cargando". Por defecto apagado para no afectar
  /// los usos existentes (dashboard, appbar, etc.).
  final bool animateRays;

  const AlDiaLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.compact = false,
    this.animateRays = false,
  });

  @override
  State<AlDiaLogo> createState() => _AlDiaLogoState();
}

class _AlDiaLogoState extends State<AlDiaLogo>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animateRays) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2400),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icono = SizedBox(
      width: widget.size,
      height: widget.size,
      child: _controller != null
          ? AnimatedBuilder(
              animation: _controller!,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LogoPainter(animationValue: _controller!.value),
                );
              },
            )
          : CustomPaint(
              painter: _LogoPainter(animationValue: null),
            ),
    );

    // Versión horizontal compacta: ícono + "AlDía", sin eslogan.
    // Pensada para espacios de altura limitada, como una AppBar.
    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icono,
          if (widget.showText) ...[
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Al',
                    style: TextStyle(
                      fontSize: widget.size * 0.62,
                      fontWeight: FontWeight.w800,
                      color: AppColors.azulPrincipal,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Día',
                    style: TextStyle(
                      fontSize: widget.size * 0.62,
                      fontWeight: FontWeight.w800,
                      color: AppColors.esmeralda,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Versión vertical completa: ícono + "AlDía" + eslogan.
    // Pensada para pantallas de login/registro con más espacio.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icono,
        if (widget.showText) ...[
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Al',
                  style: TextStyle(
                    fontSize: widget.size * 0.39,
                    fontWeight: FontWeight.w800,
                    color: AppColors.azulPrincipal,
                    fontFamily: 'Nunito',
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Día',
                  style: TextStyle(
                    fontSize: widget.size * 0.39,
                    fontWeight: FontWeight.w800,
                    color: AppColors.esmeralda,
                    fontFamily: 'Nunito',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Siempre puntual, siempre tranquilo',
            style: TextStyle(
              fontSize: widget.size * 0.19,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'Nunito',
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  /// Valor de 0.0 a 1.0 que representa el progreso del loop de animación.
  /// Si es null, los rayos se pintan a opacidad completa (sin animar),
  /// igual que el comportamiento original.
  final double? animationValue;

  _LogoPainter({this.animationValue});

  static const rayCount = 8;

  double _opacidadRayo(int i) {
    if (animationValue == null) return 1.0;
    final fase = (animationValue! - i / rayCount) % 1.0;
    final normalizada = fase < 0 ? fase + 1.0 : fase;
    // Igual curva que el keyframe CSS: mínimo 0.25, máximo 1.0,
    // con el pico exactamente a la mitad del ciclo de cada rayo.
    return 0.25 + 0.75 * (0.5 - 0.5 * math.cos(2 * math.pi * normalizada));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Rayos de sol naranjas (triángulos) — 8 rayos
    const rayLength = 0.38; // proporción del radio
    const rayWidth = 0.18; // ángulo en radianes

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i - math.pi / 2;
      final innerR = radius * 0.62;
      final outerR = radius * (1.0 - rayLength + rayLength);

      final tipX = center.dx + outerR * math.cos(angle);
      final tipY = center.dy + outerR * math.sin(angle);

      final left = Offset(
        center.dx + innerR * math.cos(angle - rayWidth),
        center.dy + innerR * math.sin(angle - rayWidth),
      );
      final right = Offset(
        center.dx + innerR * math.cos(angle + rayWidth),
        center.dy + innerR * math.sin(angle + rayWidth),
      );

      final path = Path()
        ..moveTo(tipX, tipY)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close();

      final rayPaint = Paint()
        ..color = AppColors.naranja.withOpacity(_opacidadRayo(i))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, rayPaint);
    }

    // Círculo fondo azul principal
    final circlePaint = Paint()
      ..color = AppColors.azulPrincipal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.60, circlePaint);

    // Borde sutil azul medio
    final borderPaint = Paint()
      ..color = AppColors.azulMedio.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.60, borderPaint);

    // Manecillas del reloj
    final handPaint = Paint()
      ..color = AppColors.blanco
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Manecilla hora (corta, apuntando ~10)
    handPaint.strokeWidth = size.width * 0.040;
    final hourAngle = -math.pi / 2 + (-math.pi / 3);
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.27 * math.cos(hourAngle),
        center.dy + radius * 0.27 * math.sin(hourAngle),
      ),
      handPaint,
    );

    // Manecilla minuto (larga, apuntando ~12)
    handPaint.strokeWidth = size.width * 0.032;
    final minAngle = -math.pi / 2;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.40 * math.cos(minAngle),
        center.dy + radius * 0.40 * math.sin(minAngle),
      ),
      handPaint,
    );

    // Centro del reloj (punto naranja)
    canvas.drawCircle(center, radius * 0.07, Paint()..color = AppColors.naranja);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}