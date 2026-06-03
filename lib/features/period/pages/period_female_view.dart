import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart'; // 👈 اضافه شد
import '../../../../core/providers/period_provider.dart';
import '../widgets/cycle_circle.dart';
import '../widgets/countdown_card.dart';
import '../widgets/guide_card.dart';
import '../widgets/history_section.dart';
import '../widgets/pain_chart.dart';
import 'symptom_sheet.dart';

class PeriodFemaleView extends StatelessWidget {
  final VoidCallback? onPeriodChanged;

  const PeriodFemaleView({
    super.key,
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PeriodProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // 👇 اگر CycleCircle هنوز آپدیت نشده، cycleLength رو از pp بگیر
          CycleCircle(
            currentDay: pp.currentDay,
            cycleLength: pp.cycleLength,
            periodLength: pp.periodLength,
            showAddButton: true,
            onPeriodChanged: () {
              pp.setLastPeriodStart(Jalali.now());
              onPeriodChanged?.call();
            },
          ),
          const SizedBox(height: 20),
          // 👇 CountdownCard: اگر cycleLength نمی‌گیره، باید آپدیتش کنم
          CountdownCard(
            currentDay: pp.currentDay,
            cycleLength: pp.cycleLength,
          ),
          const SizedBox(height: 16),
          // 👇 GuideCard جدید با cycleLength
          GuideCard(
            currentDay: pp.currentDay,
            cycleLength: pp.cycleLength,
            periodLength: pp.periodLength,
          ),
          const SizedBox(height: 16),
          // 👇 HistorySection جدید با List<SymptomLog>
          HistorySection(
            history: pp.history,
            onDelete: (index) => pp.deleteSymptomLog(index),
          ),
          const SizedBox(height: 16),
          // 👇 PainChart جدید با List<SymptomLog>
          PainChart(history: pp.history),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              showSymptomSheet(
                context,
                onSaved: (data) {
                  final pp = context.read<PeriodProvider>();
                  pp.addSymptomLog(SymptomLog(
                    day: pp.currentDay,
                    pain: data['pain'] ?? 0,
                    mood: data['mood'] ?? '😊',
                    symptoms: List<String>.from(data['symptoms'] ?? []),
                    date: Jalali.now(),
                  ));
                },
              );
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ثبت حال امروز',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
