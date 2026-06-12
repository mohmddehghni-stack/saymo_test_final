import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class NotesGridPainter extends CustomPainter {
  final bool isDark; // 🔥 اضافه شد

  const NotesGridPainter({this.isDark = false}); // 🔥 پارامتر جدید

  @override
  void paint(Canvas canvas, Size size) {
    // 🔥 رنگ خطوط: در تم روشن صورتی ملایم، در تم تاریک سفید محو
    final Color gridColor = isDark
        ? Colors.white.withOpacity(0.05)
        : AppColors.primaryDark.withValues(alpha: 0.06);

    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant NotesGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
