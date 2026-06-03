import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'dashed_border_painter.dart';
import '../../calendar/pages/calendar_page.dart';

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarPage()),
        );
      },
      child: Stack(
        children: [
          // اول Container
          Container(
            width: 42,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfacePrimary,
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
                        color: AppColors.shadowLight,
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
                        : AppColors.textPrimary,
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
                        : AppColors.textPrimary,
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
