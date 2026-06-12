import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'dashed_border_painter.dart';
import '../../calendar/pages/calendar_page.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/shared/widgets/navigation_helper.dart';

class CalendarCapsule extends StatelessWidget {
  final String title;
  final int number;
  final bool isSelected;
  final bool hasNote;

  const CalendarCapsule({
    super.key,
    required this.title,
    required this.number,
    required this.isSelected,
    this.hasNote = false,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => navigateTo(context, const CalendarPage()),
      child: Stack(
        children: [
          // اول Container
          Container(
            width: 42,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (appTheme?.cardBackground ?? AppColors.surfacePrimary),
              borderRadius: BorderRadius.circular(24),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: (appTheme?.shadowColor ?? AppColors.shadowLight)
                            .withOpacity(0.04), // شفافیت ملایم
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'Vazir',
                    color: isSelected
                        ? AppColors.textWhite
                        : (appTheme?.textPrimary ?? AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.textWhite
                        : (appTheme?.textPrimary ?? AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 خط‌چین روی Container
          if (hasNote)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: isSelected
                        ? Colors.white.withOpacity(0.6)
                        : const Color.fromARGB(255, 255, 63, 83)
                            .withOpacity(0.4),
                    strokeWidth: 2, // 🔥 ضخامت خط (پیش‌فرض ۱.۵)
                    dashWidth: 5, // 🔥 طول خط‌چین (پیش‌فرض ۳)
                    dashGap: 4, // 🔥 فاصله بین خط‌چین‌ها (پیش‌فرض ۳)
                    isFirst: true,
                    isLast: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
