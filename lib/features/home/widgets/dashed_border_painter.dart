import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'dart:math';

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final bool isFirst;
  final bool isLast;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 3,
    this.dashGap = 3,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final r = 20.0;

    if (isFirst && isLast) {
      // فقط یه روز: کادر کامل
      path.addRRect(RRect.fromLTRBR(
          1, 1, size.width - 1, size.height - 1, Radius.circular(r)));
    } else if (isFirst) {
      // اولین روز: بالا، پایین، چپ (با گردی)
      path.moveTo(r, 1); // شروع با کمی فاصله برای گردی
      path.lineTo(size.width, 1); // بالا-راست
      path.moveTo(size.width, size.height - 1); // پایین-راست
      path.lineTo(r, size.height - 1); // پایین-چپ
      // خط عمودی چپ با گردی
      path.moveTo(0, 1 + r);
      path.lineTo(0, size.height - 1 - r);
      path.addArc(
          Rect.fromLTWH(0, 0, r * 2, r * 2), pi, pi / 2); // گوشه بالا-چپ
      path.addArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), pi / 2,
          pi / 2); // گوشه پایین-چپ
    } else if (isLast) {
      // آخرین روز: بالا، پایین، راست (با گردی)
      path.moveTo(0, 1); // بالا-چپ
      path.lineTo(size.width - r, 1); // بالا-راست
      path.moveTo(size.width - r, size.height - 1); // پایین-راست
      path.lineTo(0, size.height - 1); // پایین-چپ
      // خط عمودی راست با گردی
      path.moveTo(size.width, 1 + r);
      path.lineTo(size.width, size.height - 1 - r);
      path.addArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), 0,
          pi / 2); // گوشه بالا-راست
      path.addArc(
          Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2),
          3 * pi / 2,
          pi / 2); // گوشه پایین-راست
    } else {
      // وسط: فقط بالا و پایین
      path.moveTo(0, 1);
      path.lineTo(size.width, 1);
      path.moveTo(size.width, size.height - 1);
      path.lineTo(0, size.height - 1);
    }

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(
            (distance + dashWidth).clamp(0, metric.length));
        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, paint);
        }
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
