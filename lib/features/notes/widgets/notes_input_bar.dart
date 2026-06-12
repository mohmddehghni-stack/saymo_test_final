import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class NotesInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const NotesInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های تطبیق‌یافته
    final Color bgColor = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF3E2723);
    final Color hintColor = appTheme?.textHint ?? Colors.grey;
    final Color inputBg =
        isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F0E8);
    final Color inputBorder =
        isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFE0D8CC);
    final Color micBg =
        isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF0ECE3);
    final Color micIcon = isDark ? Colors.white70 : const Color(0xFF5D4037);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // دکمه میکروفن
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: micBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.mic_outlined,
              color: micIcon,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          // فیلد متن
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: inputBorder, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 5,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'یادداشت‌تو بنویس...',
                  hintStyle: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: hintColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // دکمه ارسال (گرادینت برند ثابت می‌ماند)
          GestureDetector(
            onTap: onSend,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
