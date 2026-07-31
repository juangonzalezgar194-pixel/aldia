import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:aldia/theme/app_theme.dart';

class AlDiaLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AlDiaLogo({super.key, this.size = 72, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _LogoPainter(),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Al',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.azulPrincipal,
                    fontFamily: 'Nunito',
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Día',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.esmeralda,
                    fontFamily: 'Nunito',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Siempre puntual, siempre tranquilo',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grisMedio,
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
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Rayos de sol naranjas (triángulos) — 8 rayos
    final rayPaint = Paint()
      ..color = AppColors.naranja
      ..style = PaintingStyle.fill;

    const rayCount = 8;
    const rayLength = 0.38; // proporción del radio
    const rayWidth = 0.18;  // ángulo en radianes

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}