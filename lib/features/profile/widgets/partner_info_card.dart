import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/user_avatar.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class PartnerInfoCard extends StatelessWidget {
  final String? displayName;
  final String? username;
  final String? imageUrl;
  final String? gender;

  const PartnerInfoCard({
    super.key,
    this.displayName,
    this.username,
    this.imageUrl,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = displayName != null;

    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme?.cardBackground ??
            AppColors.surfacePrimary, // 👈 پس‌زمینه کارت
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isConnected)
            UserAvatar(
              username: displayName ?? 'پارتنر',
              gender: gender ?? 'male',
              imageUrl: imageUrl,
              size: 48,
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_add_rounded,
                  color: Colors.grey, size: 22),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'پارتنر 💕' : 'بدون پارتنر',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Vazir',
                    color: isConnected
                        ? AppColors.primary
                        : (appTheme?.textHint ?? AppColors.textHint), // 👈
                  ),
                ),
                if (isConnected) ...[
                  const SizedBox(height: 6),
                  Text(
                    displayName!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazir',
                      color:
                          appTheme?.textPrimary ?? AppColors.textPrimary, // 👈
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${username ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Vazir',
                      color: appTheme?.textHint ?? AppColors.textHint, // 👈
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
