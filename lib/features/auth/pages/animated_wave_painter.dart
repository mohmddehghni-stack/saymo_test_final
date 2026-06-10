import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedWavePainter extends CustomPainter {
  final double animation;

  AnimatedWavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      animation,
      Colors.white.withOpacity(.08),
      0,
      140,
    );

    _drawWave(
      canvas,
      size,
      animation,
      Colors.white.withOpacity(.12),
      1.2,
      170,
    );

    _drawWave(
      canvas,
      size,
      animation,
      Colors.white.withOpacity(.18),
      2.4,
      210,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double value,
    Color color,
    double phase,
    double baseHeight,
  ) {
    final paint = Paint()..color = color;

    final path = Path();

    path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      final y = baseHeight +
          math.sin(
                (x / size.width * 2 * math.pi) + (value * 2 * math.pi) + phase,
              ) *
              25;

      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedWavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
