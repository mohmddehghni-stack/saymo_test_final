import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class WaveLayer {
  final Color color;
  final double height;
  final double speed;
  final double amplitude;
  final double phaseOffset;

  const WaveLayer({
    required this.color,
    required this.height,
    required this.speed,
    this.amplitude = 15,
    this.phaseOffset = 0,
  });
}

class WaveBackground extends StatefulWidget {
  final List<WaveLayer> layers;
  final double containerHeight;

  const WaveBackground({
    super.key,
    required this.layers,
    this.containerHeight = 120,
  });

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.containerHeight,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              layers: widget.layers,
              animationValue: _controller.value,
              containerHeight: widget.containerHeight,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<WaveLayer> layers;
  final double animationValue;
  final double containerHeight;

  _WavePainter({
    required this.layers,
    required this.animationValue,
    required this.containerHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in layers) {
      _drawWave(canvas, size, layer);
    }
  }

  void _drawWave(Canvas canvas, Size size, WaveLayer layer) {
    final paint = Paint()
      ..color = layer.color
      ..style = PaintingStyle.fill;

    final path = Path();
    final baseY = size.height * layer.height;

    // شروع از چپ
    path.moveTo(0, baseY - layer.amplitude);

    // رسم موج
    for (double x = 0; x <= size.width; x += 1) {
      final progress = x / size.width;
      final waveY = sin(
            (progress * 2 * pi) +
                (animationValue * layer.speed * 2 * pi) +
                layer.phaseOffset,
          ) *
          layer.amplitude;

      final y = baseY + waveY;
      path.lineTo(x, y);
    }

    // برگشت از پایین
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
