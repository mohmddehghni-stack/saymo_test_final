import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/notes_manager_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class NotesPartnerList extends StatelessWidget {
  final List<NoteItem> notes;

  const NotesPartnerList({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های تطبیق‌یافته
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF3E2723);
    final Color hintColor = appTheme?.textHint ?? Colors.grey;
    final Color checkedTextColor =
        const Color(0xFFADADAD); // می‌تواند ثابت بماند
    final Color bubbleBg = isDark
        ? const Color(0xFF2D2435) // بنفش تیره مشابه فضای دارک
        : const Color(0xFFF0E6EF); // بنفش کمرنگ اصلی

    if (notes.isEmpty) {
      return Center(
        child: Text(
          'پارتنر هنوز چیزی ننوشته... 💭',
          style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 13,
              color: hintColor), // 👈 جایگزین Colors.black26
        ),
      );
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildBubble(
          notes[index],
          textColor: textColor,
          hintColor: hintColor,
          checkedTextColor: checkedTextColor,
          bubbleBg: bubbleBg,
        );
      },
    );
  }

  Widget _buildBubble(
    NoteItem note, {
    required Color textColor,
    required Color hintColor,
    required Color checkedTextColor,
    required Color bubbleBg,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleBg, // 👈 پس‌زمینه پویا
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                note.text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  // 👇 رنگ متن: اگر تیک خورده باشد از رنگ خط‌خورده، وگرنه از textColor
                  color: note.isChecked ? checkedTextColor : textColor,
                  decoration:
                      note.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.primaryDark, // رنگ خط (برند) ثابت
                  decorationThickness: 2.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.time,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 10,
                  color: hintColor, // 👈 جایگزین Colors.grey
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
