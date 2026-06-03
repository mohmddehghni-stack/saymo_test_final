import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'dart:math';

class CyclePainter extends CustomPainter {
  final int currentDay;
  final int cycleLength;
  final int periodLength;
  final Color phaseColor;
  final double pulseValue;

  CyclePainter({
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
    this.phaseColor = AppColors.primary,
    this.pulseValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 18;

    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawCircle(center, radius, bgPaint);

    _drawArcSection(
      canvas,
      center,
      radius,
      0,
      periodLength,
      AppColors.primary.withOpacity(0.8),
    );
    _drawArcSection(
      canvas,
      center,
      radius,
      12,
      4,
      Colors.amber.withOpacity(0.6),
    );
    _drawNumbers(canvas, center, radius);

    final todayAngle = -pi / 2 + (currentDay / cycleLength) * 2 * pi;
    final todayX = center.dx + radius * cos(todayAngle);
    final todayY = center.dy + radius * sin(todayAngle);

    canvas.drawCircle(
      Offset(todayX, todayY),
      16,
      Paint()..color = AppColors.primaryDark.withOpacity(0.2),
    );
    canvas.drawCircle(
      Offset(todayX, todayY),
      12,
      Paint()..color = AppColors.primaryDark,
    );
    canvas.drawCircle(Offset(todayX, todayY), 7, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(todayX, todayY),
      3,
      Paint()..color = AppColors.primaryDark,
    );
  }

  void _drawArcSection(
    Canvas canvas,
    Offset center,
    double radius,
    int startDay,
    int length,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final startAngle = -pi / 2 + (startDay / cycleLength) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      (length / cycleLength) * 2 * pi,
      false,
      paint,
    );
  }

  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    for (int i = 1; i <= cycleLength; i++) {
      final angle = -pi / 2 + (i / cycleLength) * 2 * pi;
      final x = center.dx + (radius + 20) * cos(angle);
      final y = center.dy + (radius + 20) * sin(angle);
      final isToday = i == currentDay;
      final isPeriod = i <= periodLength;
      final isOvulation = i >= 13 && i <= 16;

      Color textColor = isToday
          ? AppColors.primaryDark
          : isPeriod
              ? AppColors.primary
              : isOvulation
                  ? Colors.amber.shade700
                  : Colors.grey.shade400;

      final tp = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: isToday ? 11 : 8,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Vazir',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
