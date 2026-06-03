import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0ECE3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.mic_outlined,
              color: Color(0xFF5D4037),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE0D8CC), width: 0.5),
              ),
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  color: Color(0xFF3E2723),
                ),
                decoration: const InputDecoration(
                  hintText: 'یادداشت‌تو بنویس...',
                  hintStyle: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
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
