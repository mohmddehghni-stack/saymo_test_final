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
    final theme = Theme.of(context).extension<AppTheme>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
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
                    color: theme.textPrimary)),
          ]),
          const SizedBox(height: 16),
          _infoRow(
              context, theme, 'نام نمایشی', displayName, Icons.badge_outlined,
              onTap: () {
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
          _divider(theme),
          _infoRow(context, theme, 'نام کاربری', username,
              Icons.alternate_email_outlined, onTap: () {
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
          _divider(theme),
          _infoRow(context, theme, 'شماره تلفن', phone, Icons.phone_outlined),
          _divider(theme),
          _infoRow(
            context,
            theme,
            'جنسیت',
            gender == 'female' ? 'دختر 👧' : 'پسر 👦',
            gender == 'female' ? Icons.female_outlined : Icons.male_outlined,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, AppTheme theme, String label,
      String value, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.textHint),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Vazir', fontSize: 13, color: theme.textHint)),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimary)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 14, color: theme.textHint),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider(AppTheme theme) {
    return Container(height: 1, color: AppColors.primary.withOpacity(0.06));
  }
}
