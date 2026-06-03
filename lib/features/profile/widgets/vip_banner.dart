import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class VipBanner extends StatelessWidget {
  const VipBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xffffeb3b),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: Text(
          'vip',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            fontFamily: 'Vazir',
          ),
        ),
      ),
    );
  }
}
