import 'package:flutter/material.dart';

/// با یه انیمیشن Fade سریع ۲۰۰ms به صفحه جدید می‌ره
void navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 200), // سریع و نرم
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
