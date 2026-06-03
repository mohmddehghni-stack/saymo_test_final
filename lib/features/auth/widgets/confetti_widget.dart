import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class ConfettiWidget extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiWidget({
    super.key,
    required this.child,
    this.isPlaying = true,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiPiece> _pieces = [];
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // ساختن ۵۰ تیکه کنفتی
    for (int i = 0; i < 50; i++) {
      _pieces.add(_ConfettiPiece(
        left: _random.nextDouble(),
        size: _random.nextDouble() * 10 + 5,
        color: _colors[_random.nextInt(_colors.length)],
        delay: _random.nextDouble() * 2,
        rotation: _random.nextDouble() * 6.28,
        shape: _random.nextBool() ? ConfettiShape.circle : ConfettiShape.square,
      ));
    }

    if (widget.isPlaying) _controller.forward();
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _colors = [
    AppColors.primary,
    AppColors.primaryDark,
    Color(0xFFFFB6C1),
    Color(0xFFFFD700),
    Color(0xFFFF8A80),
    Color(0xFFBA68C8),
    Color(0xFF4FC3F7),
    Color(0xFFFFF176),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._pieces.map((piece) {
          final startDelay = piece.delay;
          final endTime = startDelay + 2.0; // ۲ ثانیه سقوط

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress =
                  ((_controller.value - startDelay / 4) / (endTime / 4))
                      .clamp(0.0, 1.0);

              final top = progress * MediaQuery.of(context).size.height;
              final left = piece.left * MediaQuery.of(context).size.width;
              final opacity = (1.0 - progress).clamp(0.0, 1.0);
              final rotation = piece.rotation + (progress * 10);
              final scale = 1.0 - (progress * 0.8);

              if (progress == 0.0 || progress == 1.0) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: top - 50,
                left: left,
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: piece.size,
                        height: piece.shape == ConfettiShape.square
                            ? piece.size
                            : piece.size * 1.5,
                        decoration: BoxDecoration(
                          color: piece.color,
                          borderRadius: piece.shape == ConfettiShape.circle
                              ? BorderRadius.circular(piece.size)
                              : BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _ConfettiPiece {
  final double left;
  final double size;
  final Color color;
  final double delay;
  final double rotation;
  final ConfettiShape shape;

  _ConfettiPiece({
    required this.left,
    required this.size,
    required this.color,
    required this.delay,
    required this.rotation,
    required this.shape,
  });
}

enum ConfettiShape { circle, square }
