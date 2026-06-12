import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class ProfileIdCard extends StatelessWidget {
  final String publicId;
  final VoidCallback onCopy;

  const ProfileIdCard({
    super.key,
    required this.publicId,
    required this.onCopy,
  });

  String _formatId(String id) {
    if (id.length != 8) return id;
    return '${id.substring(0, 2)} ${id.substring(2, 4)} ${id.substring(4, 6)} ${id.substring(6, 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color cardBg = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
    final Color shadowColor = appTheme?.shadowColor ?? const Color(0x0F000000);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // عنوان
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fingerprint,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'آیدی من',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // عدد آیدی
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _formatId(publicId),
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 6,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // دکمه‌ها
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: publicId));
                    onCopy();
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label:
                      const Text('کپی', style: TextStyle(fontFamily: 'Vazir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    // 👇 رنگ متن دکمه: در هر دو تم سفید بماند (خوانا)
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Share.share(
                        'آیدی من توی سایمو: $publicId\nبا این آیدی می‌تونی بهم وصل بشی! 💕');
                  },
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('اشتراک',
                      style: TextStyle(fontFamily: 'Vazir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
