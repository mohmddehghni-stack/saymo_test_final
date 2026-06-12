import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../../../core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class NoteInput extends StatefulWidget {
  final int selectedDay;
  final CalendarProvider calendarProvider;

  const NoteInput(
      {super.key, required this.selectedDay, required this.calendarProvider});

  @override
  State<NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<NoteInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_controller.text.trim().isNotEmpty) {
      widget.calendarProvider
          .addNote(widget.selectedDay, _controller.text.trim());
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('یادداشت ثبت شد! ✅', style: TextStyle(fontFamily: 'Vazir'))
          ]),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 گرفتن تم و وضعیت
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های تطبیق‌یافته
    final Color bgColor = isDark
        ? (appTheme?.cardBackground ?? const Color(0xFF1E1E1E))
        : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final Color hintColor = textColor.withOpacity(0.4);
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFEAEAEA);
    final Color inputBg =
        isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F5F5);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('یادداشت روز ${widget.selectedDay}',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        blurRadius: 4)
                  ],
                ),
                child: Text('روز ${widget.selectedDay}',
                    style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor.withOpacity(0.8)),
            ),
            child: TextField(
              controller: _controller,
              textDirection: TextDirection.rtl,
              minLines: 3,
              maxLines: 5,
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  color: textColor,
                  height: 1.6),
              decoration: InputDecoration(
                hintText: 'اینجا بنویس... ✍️',
                hintStyle: TextStyle(
                    fontFamily: 'Vazir', fontSize: 13, color: hintColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${_controller.text.length}/500',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 10,
                      color: _controller.text.length > 450
                          ? Colors.orange
                          : textColor.withOpacity(0.4))),
              const Spacer(),
              GestureDetector(
                onTap: _saveNote,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.3),
                          blurRadius: 6)
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('ثبت',
                          style: TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
