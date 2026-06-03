import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../../shared/pages/support_page.dart';

class SupportButton extends StatelessWidget {
  const SupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 75),
      width: double.infinity,
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SupportPage()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfacePrimary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.primary.withOpacity(0.15)),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.headset_mic_outlined,
              color: AppColors.primary, size: 22),
          label: const Text(
            'پشتیبانی',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Vazir',
            ),
          ),
        ),
      ),
    );
  }
}
