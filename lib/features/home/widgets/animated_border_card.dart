import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class AnimatedBorderCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final double height;

  const AnimatedBorderCard({
    super.key,
    required this.child,
    this.color = const Color(0xFFE87984),
    this.height = 220,
  });

  @override
  State<AnimatedBorderCard> createState() => _AnimatedBorderCardState();
}

class _AnimatedBorderCardState extends State<AnimatedBorderCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            // 🔥 گرادیانت ساده پشت کارت
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color
                    .withOpacity(0.03 + sin(_controller.value * pi) * 0.02),
                Colors.transparent,
                widget.color
                    .withOpacity(0.03 + cos(_controller.value * pi) * 0.02),
              ],
            ),
          ),
          // 🔥 border با رنگ متحرک
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment(_controller.value * 2 - 1, -1),
                end: Alignment(1 - _controller.value * 2, 1),
                colors: [
                  widget.color.withOpacity(0.2),
                  widget.color.withOpacity(0.05),
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.05),
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.surfacePrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
