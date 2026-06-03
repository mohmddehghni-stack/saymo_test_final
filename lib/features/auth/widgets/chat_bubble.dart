import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isHighlighted;
  final bool isCentered;

  const ChatBubble({
    super.key,
    required this.text,
    this.isUser = false,
    this.isHighlighted = false,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCentered
          ? Alignment.center
          : isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : isHighlighted
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: isHighlighted
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 13,
            color: isUser ? Colors.white : const Color(0xFF5D4037),
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }
}
