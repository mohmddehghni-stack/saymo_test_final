import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class InviteBanner extends StatelessWidget {
  const InviteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.periodBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'با هر دعوت یک زوج جایزه نقدی بگیر',
                style: TextStyle(
                  color: Color(0xff333333),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.share, color: Color(0xfff0627e), size: 24),
          ),
        ],
      ),
    );
  }
}
