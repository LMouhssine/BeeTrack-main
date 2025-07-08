import 'package:flutter/material.dart';
import 'dart:math' as math;

class BeeLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? beeColor;

  const BeeLogo({
    Key? key,
    this.size = 60.0,
    this.color,
    this.beeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hexColor = color ?? Theme.of(context).primaryColor;
    final bee = beeColor ?? Colors.amber.shade300;

    return CustomPaint(
      size: Size(size, size),
      painter: BeeLogoPainter(
        hexagonColor: hexColor,
        beeColor: bee,
      ),
    );
  }
}

class BeeLogoPainter extends CustomPainter {
  final Color hexagonColor;
  final Color beeColor;

  BeeLogoPainter({
    required this.hexagonColor,
    required this.beeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Dessiner l'hexagone de fond
    _drawHexagon(canvas, center, radius, hexagonColor);

    // Dessiner l'abeille
    _drawBee(canvas, center, size.width * 0.3);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = center.dx + radius * 1.5 * cos(angle);
      final y = center.dy + radius * 1.5 * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBee(Canvas canvas, Offset center, double scale) {
    final beePaint = Paint()
      ..color = beeColor
      ..style = PaintingStyle.fill;

    final stripePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    final wingPaint = Paint()
      ..color = beeColor.withAlpha((0.7 * 255).round())
      ..style = PaintingStyle.fill;

    // Corps principal de l'abeille (ellipse verticale)
    final bodyRect = Rect.fromCenter(
      center: center,
      width: scale * 0.5,
      height: scale * 0.8,
    );
    canvas.drawOval(bodyRect, beePaint);

    // Rayures sur le corps
    final stripeHeight = scale * 0.08;
    for (int i = 0; i < 4; i++) {
      final stripeY = center.dy - scale * 0.25 + (i * scale * 0.15);
      final stripeRect = Rect.fromCenter(
        center: Offset(center.dx, stripeY),
        width: scale * 0.5,
        height: stripeHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(stripeRect, const Radius.circular(2)),
        stripePaint,
      );
    }

    // Tête
    final headCenter = Offset(center.dx, center.dy - scale * 0.5);
    canvas.drawCircle(headCenter, scale * 0.15, beePaint);

    // Antennes
    final antennaePaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = scale * 0.04
      ..strokeCap = StrokeCap.round;

    // Antenne gauche
    canvas.drawLine(
      Offset(headCenter.dx - scale * 0.08, headCenter.dy - scale * 0.08),
      Offset(headCenter.dx - scale * 0.15, headCenter.dy - scale * 0.2),
      antennaePaint,
    );
    canvas.drawCircle(
      Offset(headCenter.dx - scale * 0.15, headCenter.dy - scale * 0.2),
      scale * 0.03,
      stripePaint,
    );

    // Antenne droite
    canvas.drawLine(
      Offset(headCenter.dx + scale * 0.08, headCenter.dy - scale * 0.08),
      Offset(headCenter.dx + scale * 0.15, headCenter.dy - scale * 0.2),
      antennaePaint,
    );
    canvas.drawCircle(
      Offset(headCenter.dx + scale * 0.15, headCenter.dy - scale * 0.2),
      scale * 0.03,
      stripePaint,
    );

    // Ailes
    final leftWingCenter = Offset(center.dx - scale * 0.3, center.dy - scale * 0.1);
    final rightWingCenter = Offset(center.dx + scale * 0.3, center.dy - scale * 0.1);

    // Aile gauche
    canvas.save();
    canvas.translate(leftWingCenter.dx, leftWingCenter.dy);
    canvas.rotate(-0.3); // Rotation de -20 degrés
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: scale * 0.3, height: scale * 0.6),
      wingPaint,
    );
    canvas.restore();

    // Aile droite
    canvas.save();
    canvas.translate(rightWingCenter.dx, rightWingCenter.dy);
    canvas.rotate(0.3); // Rotation de 20 degrés
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: scale * 0.3, height: scale * 0.6),
      wingPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Fonction helper pour cos et sin
double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians); 