import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/providers/period_provider.dart';
import 'cycle_painter.dart';

class CycleCircle extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final int periodLength;
  final bool showAddButton;
  final VoidCallback? onPeriodChanged;

  const CycleCircle({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
    this.showAddButton = true,
    this.onPeriodChanged,
  });

  /// گرفتن رنگ بر اساس فاز
  Color _getPhaseColor(PeriodProvider pp) {
    final phase = pp.currentPhase;
    switch (phase) {
      case 'قاعدگی':
        return AppColors.primary;
      case 'فولیکولار':
        return const Color(0xFF5B8DEF);
      case 'تخمک‌گذاری':
        return const Color(0xFF4CAF50);
      case 'لوتئال اولیه':
        return Colors.amber.shade600;
      case 'PMS':
        return Colors.deepOrange.shade400;
      default:
        return AppColors.primaryDark;
    }
  }

  /// گرفتن ایموجی بر اساس فاز
  String _getPhaseEmoji(PeriodProvider pp) {
    final phase = pp.currentPhase;
    switch (phase) {
      case 'قاعدگی':
        return '🩸';
      case 'فولیکولار':
        return '🌸';
      case 'تخمک‌گذاری':
        return '✨';
      case 'لوتئال اولیه':
        return '🌙';
      case 'PMS':
        return '😤';
      default:
        return '📅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.read<PeriodProvider>();
    final phaseColor = _getPhaseColor(pp);
    final phaseEmoji = _getPhaseEmoji(pp);

    return Column(
      children: [
        // ─── دایره چرخه با انیمیشن پالس ───
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  phaseColor.withOpacity(0.1),
                  phaseColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: phaseColor.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: phaseColor.withOpacity(0.08),
                  blurRadius: 80,
                  spreadRadius: 15,
                ),
              ],
            ),
            child: SizedBox(
              height: 250,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: CyclePainter(
                      currentDay: currentDay,
                      cycleLength: cycleLength,
                      periodLength: periodLength,
                      phaseColor: phaseColor, // 🔥 رنگ فاز
                    ),
                  ),
                  // 🔥 ایموجی وسط
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phaseEmoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pp.currentPhase,
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ─── روز چرخه با گرادیانت فاز ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [phaseColor, phaseColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: phaseColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'روز $currentDay از $cycleLength',
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (pp.daysUntilNextPeriod > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${pp.daysUntilNextPeriod} روز تا پریود بعدی',
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── راهنما ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem(AppColors.primary, 'پریود'),
              _legendItem(Colors.amber.shade600, 'تخمک‌گذاری'),
              _legendItem(const Color(0xFF5B8DEF), 'باروری'),
              _legendItem(phaseColor, 'امروز'),
            ],
          ),
        ),

        // ─── دکمه ثبت شروع پریود جدید ───
        if (showAddButton) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await pp.markPeriodToday(); // 🔥 صبر کن تا ذخیره بشه
              onPeriodChanged?.call();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '🩸 پریود امروز ثبت شد!',
                    style: TextStyle(fontFamily: 'Vazir'),
                  ),
                  backgroundColor: phaseColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: phaseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: phaseColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bloodtype, color: phaseColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'امروز پریود شدم 🩸',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: phaseColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 11,
            color: Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }
}
