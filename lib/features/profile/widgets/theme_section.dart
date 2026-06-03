import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart'; // 🔥 اضافه کن
import 'package:flutter_application_1/core/providers/app_provider.dart'; // 🔥 اضافه کن

class ThemeSection extends StatefulWidget {
  const ThemeSection({super.key});

  @override
  State<ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<ThemeSection> {
  int _selectedTheme = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // عنوان
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_outlined,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('رنگ‌بندی',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('به‌زودی ✨',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 10,
                      color: AppColors.primary)),
            ),
          ]),

          const SizedBox(height: 16),

          // دایره‌های رنگ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _colorDot(0, const Color(0xFF2196F3)),
              _colorDot(1, const Color(0xFF9C27B0)),
              _colorDot(2, AppColors.primary),
              _colorDot(3, const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorDot(int index, Color color) {
    final isActive = index == _selectedTheme;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTheme = index);

        // 🔥 دایره اول (آبی) = Dark Mode
        if (index == 0) {
          if (!context.read<AppProvider>().isDarkMode) {
            context.read<AppProvider>().toggleDarkMode();
          }
        }
        // 🔥 دایره سوم (صورتی) = Light Mode
        if (index == 2) {
          if (context.read<AppProvider>().isDarkMode) {
            context.read<AppProvider>().toggleDarkMode();
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: isActive ? 36 : 26,
        height: isActive ? 36 : 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2)
                ]
              : [],
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}
