import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_application_1/features/home/widgets/dashed_border_painter.dart';

class DayCell extends StatelessWidget {
  final int? day;
  final bool isActive;
  final bool isToday;
  final bool hasPeriod;
  final bool periodIsFirst;
  final bool periodIsLast;
  final bool hasNote;
  final bool hasMoment;
  final bool isMyNote;
  final bool isPartnerNote;
  final bool isPast;
  final bool hasFertile;
  final bool isOvulationDay;
  final bool fertileIsFirst;
  final bool fertileIsLast;
  final bool hasPredictedPeriod;
  final bool predictedIsFirst;
  final bool predictedIsLast;

  const DayCell({
    super.key,
    this.day,
    this.isActive = false,
    this.isToday = false,
    this.hasPeriod = false,
    this.periodIsFirst = false,
    this.periodIsLast = false,
    this.hasNote = false,
    this.hasMoment = false,
    this.isMyNote = false,
    this.isPartnerNote = false,
    this.isPast = false,
    this.hasFertile = false,
    this.isOvulationDay = false,
    this.fertileIsFirst = false,
    this.fertileIsLast = false,
    this.hasPredictedPeriod = false,
    this.predictedIsFirst = false,
    this.predictedIsLast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox();

    Color textColor = isActive
        ? Colors.white
        : isPast
            ? Colors.black.withOpacity(0.35)
            : Colors.black.withOpacity(0.8);

    // ─── محاسبه گوشه‌های هایلایت ───
    BorderRadiusGeometry borderRadius;
    if (hasPeriod || hasFertile || hasPredictedPeriod) {
      // ─── اول یا آخر بودن رو چک کن ───
      final isFirst = periodIsFirst || fertileIsFirst || predictedIsFirst;
      final isLast = periodIsLast || fertileIsLast || predictedIsLast;

      if (isFirst && isLast) {
        borderRadius = BorderRadius.circular(10);
      } else if (isFirst) {
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
      } else if (isLast) {
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
      } else {
        borderRadius = BorderRadius.zero; // 👈 وسط: کاملاً صاف
      }
    } else {
      borderRadius = BorderRadius.circular(8);
    }

    return SizedBox(
      width: 36,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ─── هایلایت پیش‌بینی پریود (خط‌چین صورتی) ───
          if (hasPredictedPeriod && !hasPeriod && !hasFertile)
            Positioned.fill(
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFFFFB6C1).withOpacity(0.5),
                  isFirst: predictedIsLast, // 👈 اونی که LAST بود رو بذار FIRST
                  isLast: predictedIsFirst, // 👈 اونی که FIRST بود رو بذار LAST
                ),
              ),
            ),
          // ─── هایلایت پنجره باروری (بنفش کمرنگ) ───
          if (hasFertile && !hasPeriod)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.06),
                  borderRadius: borderRadius,
                ),
              ),
            ),

          // ─── هایلایت پریود (قرمز) ───
          if (hasPeriod)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isPast
                      ? const Color(0xFFF5576C).withOpacity(0.1)
                      : const Color(0xFFF5576C).withOpacity(0.18),
                  borderRadius: borderRadius,
                ),
              ),
            ),

          // ─── عدد روز ───
          // ─── عدد روز ───
          Center(
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive && !isToday
                      ? AppColors.primaryDark
                      : isOvulationDay
                          ? Colors.deepPurple
                              .withOpacity(0.5) // 👈 حلقه بنفش برای تخمک‌گذاری
                          : Colors.transparent,
                  width: isActive || isOvulationDay ? 2.5 : 0.8,
                ),
                color: isToday && isActive
                    ? AppColors.primaryDark
                    : Colors.transparent,
                boxShadow: isToday && isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isActive
                      ? (isToday ? Colors.white : AppColors.primaryDark)
                      : isOvulationDay
                          ? Colors.deepPurple
                              .withOpacity(0.7) // 👈 عدد بنفش برای تخمک‌گذاری
                          : textColor,
                  fontSize: 12,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ─── نقطه‌های یادداشت و لحظه (زیر عدد) ───
          // ─── نقطه‌های یادداشت و لحظه (زیر عدد) ───
          if (hasNote || hasMoment)
            Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔥 نقطه یادداشت خودم
                  if (isMyNote)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  // 🔥 نقطه یادداشت پارتنر
                  if (isPartnerNote)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: Colors.pink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  // 🔥 نقطه moment
                  if (hasMoment)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class WeekDayLabel extends StatelessWidget {
  final String label;
  const WeekDayLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Vazir',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
