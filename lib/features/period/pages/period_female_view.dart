import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/providers/period_provider.dart';
import '../widgets/cycle_circle.dart';
import '../widgets/countdown_card.dart';
import '../widgets/guide_card.dart';
import '../widgets/history_section.dart';
import '../widgets/pain_chart.dart';
import 'symptom_sheet.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class PeriodFemaleView extends StatelessWidget {
  final VoidCallback? onPeriodChanged;

  const PeriodFemaleView({
    super.key,
    this.onPeriodChanged,
  });

  static const Color primaryPink = Color(0xFFFE4773);
  static const Color primaryPurple = Color(0xFF862AF5);

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PeriodProvider>();

    // 🔥 تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const SizedBox(height: 30),
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
          CountdownCard(
            currentDay: pp.currentDay,
            cycleLength: pp.cycleLength,
          ),
          const SizedBox(height: 16),
          GuideCard(
            currentDay: pp.currentDay,
            cycleLength: pp.cycleLength,
            periodLength: pp.periodLength,
          ),
          const SizedBox(height: 16),
          HistorySection(
            history: pp.history,
            onDelete: (index) => pp.deleteSymptomLog(index),
          ),
          const SizedBox(height: 16),
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
                      colors: [primaryPink, primaryPurple],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryPink.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'ثبت حال امروز',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    // 👇 متن در تم تاریک روشن‌تر می‌شود
                    color: appTheme?.textHint ?? const Color(0xFF8E8E98),
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
