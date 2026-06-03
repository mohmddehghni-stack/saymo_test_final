import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class NoteDetailDialog {
  static const Color primaryPink = AppColors.primary;
  static const Color deepPink = Color(0xFFE8456B);
  static const Color partnerBlue = Color(0xFF5B8DEF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8E8E98);
  static const Color softBg = AppColors.backgroundLight;

  static void show(
    BuildContext context, {
    required String dateStr,
    required String note,
    required bool isMyNote,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isMyNote
                            ? [deepPink, primaryPink]
                            : [partnerBlue, const Color(0xFF7EB3FF)],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isMyNote ? Icons.person : Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyNote ? 'یادداشت من' : 'یادداشت پارتنر',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isMyNote ? primaryPink : partnerBlue,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                    color: textGrey,
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  note,
                  style: const TextStyle(
                    fontSize: 15,
                    color: textDark,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
