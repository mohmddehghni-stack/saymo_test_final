import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/theme_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme?.cardBackground ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (appTheme?.shadowColor ?? Colors.black).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDark ? 'تم تاریک' : 'تم روشن',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: appTheme?.textPrimary ?? Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDark ? 'حالت شب' : 'حالت روز',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 12,
                    color: appTheme?.textHint ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) {
              themeProvider.setThemeMode(
                val ? ThemeMode.dark : ThemeMode.light,
              );
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
