import 'package:flutter/material.dart';

class ProfileShimmer extends StatefulWidget {
  const ProfileShimmer({super.key});

  @override
  State<ProfileShimmer> createState() => _ProfileShimmerState();
}

class _ProfileShimmerState extends State<ProfileShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.3 + (_controller.value * 0.3);
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              // شبیه‌سازی ProfileHeader
              _shimmerCard(170, 60, opacity, isDark),
              const SizedBox(height: 16),
              // کارت آیدی
              _shimmerCard(100, 40, opacity, isDark),
              const SizedBox(height: 12),
              // کارت پارتنر
              _shimmerCard(80, 40, opacity, isDark),
              const SizedBox(height: 12),
              // کارت اطلاعات
              _shimmerCard(150, 60, opacity, isDark),
              const SizedBox(height: 12),
              // کارت وضعیت
              _shimmerCard(120, 40, opacity, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerCard(
      double width, double height, double opacity, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            (isDark ? Colors.white : Colors.black).withOpacity(opacity * 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
