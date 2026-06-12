import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class ProfilePartnerCard extends StatelessWidget {
  final bool isConnected;
  final String? partnerName;

  const ProfilePartnerCard({
    super.key,
    this.isConnected = false,
    this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color cardBg = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
    final Color hintColor = appTheme?.textHint ?? const Color(0xFF8E8E98);
    final Color shadowColor = appTheme?.shadowColor ?? const Color(0x0F000000);
    final Color neutralGrey =
        hintColor; // استفاده از hintColor به‌جای خاکستری ثابت

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
      child: Row(
        children: [
          // آیکن
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.primary.withOpacity(0.08)
                  : neutralGrey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isConnected ? Icons.favorite_rounded : Icons.person_add_rounded,
              color: isConnected ? AppColors.primary : neutralGrey,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // متن
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'متصل به پارتنر ' : 'بدون پارتنر',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? AppColors.primary : neutralGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConnected ? partnerName ?? '' : 'می‌تونی با آیدی وصل بشی',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 12,
                    color: hintColor,
                  ),
                ),
              ],
            ),
          ),
          // وضعیت
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? const Color(0xFF4CAF50)
                  : neutralGrey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
