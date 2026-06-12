import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/features/auth/pages/welcome_screen.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

void showLogoutDialog(BuildContext context) {
  // 🔥 دریافت تم
  final appTheme = Theme.of(context).extension<AppTheme>();

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: appTheme?.cardBackground ??
          AppColors.surfacePrimary, // 👈 پس‌زمینه پویا
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'خروج از حساب',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appTheme?.textPrimary ?? AppColors.textPrimary, // 👈
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'آیا مطمئنی می‌خوای خارج بشی؟',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                color: appTheme?.textHint ?? AppColors.textHint, // 👈
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          appTheme?.textPrimary ?? AppColors.textPrimary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('منصرف شدم',
                        style: TextStyle(fontFamily: 'Vazir', fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AppProvider>().logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('خروج',
                        style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 14,
                            color: Colors.white)),
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
