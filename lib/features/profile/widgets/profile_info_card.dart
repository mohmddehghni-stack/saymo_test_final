import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'edit_dialog.dart';

class ProfileInfoCard extends StatelessWidget {
  final String displayName;
  final String username;
  final String phone;
  final String gender;

  const ProfileInfoCard({
    super.key,
    required this.displayName,
    required this.username,
    required this.phone,
    required this.gender,
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
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text('اطلاعات کاربری',
                style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ]),
          const SizedBox(height: 16),
          _infoRow(context, 'نام نمایشی', displayName, Icons.badge_outlined,
              hintColor: hintColor, textColor: textColor, onTap: () {
            showEditDialog(
              context: context,
              title: 'نام نمایشی',
              currentValue: displayName,
              onSave: (newValue) async {
                await context
                    .read<AppProvider>()
                    .updateProfile(displayName: newValue);
              },
            );
          }),
          _divider(),
          _infoRow(
              context, 'نام کاربری', username, Icons.alternate_email_outlined,
              hintColor: hintColor, textColor: textColor, onTap: () {
            showEditDialog(
              context: context,
              title: 'نام کاربری',
              currentValue: username,
              onSave: (newValue) async {
                await context
                    .read<AppProvider>()
                    .updateProfile(username: newValue);
              },
            );
          }),
          _divider(),
          _infoRow(context, 'شماره تلفن', phone, Icons.phone_outlined,
              hintColor: hintColor, textColor: textColor),
          _divider(),
          _infoRow(
            context,
            'جنسیت',
            gender == 'female' ? 'دختر 👧' : 'پسر 👦',
            gender == 'female' ? Icons.female_outlined : Icons.male_outlined,
            hintColor: hintColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, String label, String value, IconData icon,
      {required Color hintColor,
      required Color textColor,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: hintColor),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Vazir', fontSize: 13, color: hintColor)),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 14, color: hintColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1, color: AppColors.primary.withOpacity(0.06));
  }
}
