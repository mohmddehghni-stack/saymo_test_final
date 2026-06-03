import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class WaveHeader extends StatefulWidget {
  final Widget child;
  final double waveHeight;

  const WaveHeader({
    super.key,
    required this.child,
    this.waveHeight = 20,
  });

  @override
  State<WaveHeader> createState() => _WaveHeaderState();
}

class _WaveHeaderState extends State<WaveHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 👈 تندتر
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return ClipPath(
              clipper: _WaveClipper(
                waveHeight: widget.waveHeight,
                waveOffset: _waveController.value,
              ),
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8456B),
                      AppColors.primary,
                      Color(0xFFFF8E9E),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double waveHeight;
  final double waveOffset;

  _WaveClipper({required this.waveHeight, required this.waveOffset});

  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - waveHeight);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height -
          waveHeight +
          waveHeight * 1.5 * waveOffset, // 👈 دامنه بیشتر
      size.width * 0.5,
      size.height - waveHeight,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height -
          waveHeight -
          waveHeight * 1.5 * waveOffset, // 👈 دامنه بیشتر
      size.width,
      size.height - waveHeight,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) {
    return oldClipper.waveOffset != waveOffset;
  }
}
