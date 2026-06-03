import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';

class CountdownCard extends StatelessWidget {
  final int currentDay;
  final int cycleLength;

  const CountdownCard({
    super.key,
    required this.currentDay,
    required this.cycleLength,
  });

  @override
  Widget build(BuildContext context) {
    final pp = context.read<PeriodProvider>();
    final daysLeft = cycleLength - currentDay;
    final progress = currentDay / cycleLength;

    String title;
    String subtitle;
    Color accentColor;
    String emoji;

    if (pp.isOnPeriod) {
      title = 'در دوره پریود';
      subtitle = '${pp.periodLength - currentDay + 1} روز دیگه تموم می‌شه';
      accentColor = AppColors.primary;
      emoji = '🩸';
    } else if (daysLeft <= 3) {
      title = 'پریود نزدیکه';
      subtitle = '$daysLeft روز دیگه';
      accentColor = AppColors.primary;
      emoji = '🔔';
    } else if (currentDay >= cycleLength - 16 &&
        currentDay <= cycleLength - 12) {
      title = 'روزای طلایی';
      subtitle = '$daysLeft روز تا پریود بعدی';
      accentColor = const Color(0xFFD4A017);
      emoji = '✨';
    } else {
      title = 'همه چی آرومه';
      subtitle = '$daysLeft روز تا پریود بعدی';
      accentColor = const Color(0xFF6B8FCE);
      emoji = '🌸';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── هدر ───
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              // ─── دایره پروگرس ───
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3.5,
                      backgroundColor: accentColor.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ─── پروگرس بار پایین ───
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: accentColor.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),

          const SizedBox(height: 8),

          // ─── لیبل‌های زیر ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('روز ۱',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 10,
                      color: Colors.grey.shade400)),
              Text(
                'امروز: روز $currentDay',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor.withOpacity(0.7),
                ),
              ),
              Text('روز $cycleLength',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 10,
                      color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}
