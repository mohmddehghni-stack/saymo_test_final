import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/user_avatar.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String userId;
  final String gender;
  final String? imageUrl;
  final VoidCallback onLogout;
  final VoidCallback? onCameraTap;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.userId,
    required this.gender,
    this.imageUrl,
    required this.onLogout,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ پس‌زمینه: در شب یک رنگ تیره ساده، در روز همون گرادینت برند
    final Color darkBgColor =
        appTheme?.cardBackground ?? const Color(0xFF1E1E1E);

    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        // اگر شب بود → رنگ تخت (بدون گرادینت)، در غیر این صورت → گرادینت برند
        gradient: isDark
            ? null // حذف گرادینت
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? darkBgColor : null, // رنگ ثابت فقط در شب
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              username: username,
              gender: gender,
              imageUrl: imageUrl,
              size: 72,
              showCameraButton: true,
              onCameraTap: onCameraTap,
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Vazir')),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('ID: $userId',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Vazir')),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onLogout,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
