import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class InvitationDialog extends StatelessWidget {
  final String hostName;
  final String title;
  final String message;
  final String acceptText;
  final String rejectText;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const InvitationDialog({
    super.key,
    required this.hostName,
    this.title = 'دعوت به سینما 🎬',
    this.message = 'تو رو به یه سینمای خصوصی دعوت کرده! 🍿',
    this.acceptText = 'آره، بیا بریم! 🍿',
    this.rejectText = 'نه، ممنون',
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2D1B3A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 👈 ایموجی بر اساس نوع دعوت
              Text(
                title.contains('مجدد') ? '🔄' : '🎬',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),

              // 👈 نام میزبان
              Text(
                '$hostName عزیز',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 👈 پیام (قابل تنظیم)
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Vazir',
                ),
              ),
              const SizedBox(height: 24),

              // 👈 دکمه‌ها
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white38,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        rejectText,
                        style: const TextStyle(fontFamily: 'Vazir'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: Text(
                        acceptText,
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
