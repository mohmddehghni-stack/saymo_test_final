import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class AddNoteSheet {
  static const Color primaryPink = AppColors.primary;
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8E8E98);
  static const Color softBg = AppColors.backgroundLight;

  static void show(BuildContext context, CalendarProvider cp) {
    final noteController = TextEditingController();
    String selectedType = 'note';
    bool isPrivate = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ثبت جدید ✨',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  cp.selectedDay != null
                      ? cp.formatDate(cp.selectedDay!)
                      : 'روزی انتخاب نشده',
                  style: TextStyle(fontSize: 13, color: textGrey),
                ),
                const SizedBox(height: 18),

                // 👈 گزینه‌های نوع
                Row(
                  children: [
                    _buildTypeOption(
                      '📝',
                      'یادداشت',
                      selectedType == 'note',
                      () => setSheetState(() => selectedType = 'note'),
                    ),
                    const SizedBox(width: 8),
                    _buildTypeOption(
                      '💌',
                      'خاطره',
                      selectedType == 'memory',
                      () => setSheetState(() => selectedType = 'memory'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 👈 بخش خاطره (نکته آموزشی تکراری)
                if (selectedType == 'memory') ...[
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '🔄 این خاطره هرسال تکرار میشه',
                      style: TextStyle(fontSize: 12, color: textGrey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    autofocus: true,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14, color: textDark),
                    decoration: InputDecoration(
                      hintText: 'خاطرت رو بنوس...',
                      hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                      filled: true,
                      fillColor: softBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 👈 بخش یادداشت (متن آزاد)
                if (selectedType == 'note') ...[
                  TextField(
                    controller: noteController,
                    autofocus: true,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: textDark),
                    decoration: InputDecoration(
                      hintText: 'یادداشتت رو بنویس...',
                      hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                      filled: true,
                      fillColor: softBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 👈 سوییچ خصوصی
                Row(
                  children: [
                    const Text('فقط برای خودم',
                        style: TextStyle(fontSize: 13, color: textDark)),
                    const Spacer(),
                    Switch(
                      value: isPrivate,
                      onChanged: (v) => setSheetState(() => isPrivate = v),
                      activeColor: primaryPink,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 👈 دکمه ثبت
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (noteController.text.trim().isNotEmpty) {
                        final day = cp.selectedDay;
                        if (day != null) {
                          cp.addNote(
                            day,
                            noteController.text.trim(),
                            isPrivate: isPrivate,
                            isRecurring: selectedType == 'memory',
                          );
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'ثبت 💕',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildTypeOption(
    String emoji,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primaryPink.withOpacity(0.08) : softBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected ? primaryPink.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? primaryPink : textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
