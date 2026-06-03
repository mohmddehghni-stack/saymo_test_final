// lib/shared/widgets/locked_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class LockedWidget extends StatelessWidget {
  final Widget child;
  final String message;

  const LockedWidget({
    super.key,
    required this.child,
    this.message = 'پارتنرت رو دعوت کن 💕',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: 0.5, child: IgnorePointer(child: child)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded,
                      size: 36, color: AppColors.textHint),
                  const SizedBox(height: 8),
                  Text(message,
                      style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          color: AppColors.textHint)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
