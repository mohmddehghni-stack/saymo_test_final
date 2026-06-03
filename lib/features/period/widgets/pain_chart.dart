import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../../../core/providers/period_provider.dart';

class PainChart extends StatelessWidget {
  final List<SymptomLog> history;
  String _monthName(int month) {
    const months = [
      '',
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند'
    ];
    return months[month];
  }

  const PainChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final last7Days = history.take(7).toList().reversed.toList();

    final maxPain = last7Days
        .map((e) => e.pain)
        .fold<int>(0, (max, p) => p > max ? p : max);
    final effectiveMax = maxPain > 0 ? maxPain : 5;

    const accentColor = AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── هدر ───
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                '📊 نمودار درد',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444444),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '۷ روز اخیر',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ─── نمودار ───
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: last7Days.map((log) {
                final pain = log.pain;
                final height =
                    effectiveMax > 0 ? (pain / effectiveMax) * 60 + 4 : 4.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // عدد درد
                    Text(
                      pain > 0 ? '$pain' : '',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accentColor.withOpacity(pain > 0 ? 0.8 : 0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // میله
                    Container(
                      width: 26,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            accentColor.withOpacity(0.25),
                            accentColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // تاریخ
                    Text(
                      '${log.date.day} ${_monthName(log.date.month)}', // 🔥 مثل history_section
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // ─── پیام بدون درد ───
          if (last7Days.every((e) => e.pain == 0))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  '😊 هیچ دردی ثبت نشده!',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
