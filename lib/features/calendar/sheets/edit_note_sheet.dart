import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class EditNoteSheet {
  static const Color primaryPink = AppColors.primary;
  static const Color deepPink = Color(0xFFE8456B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8E8E98);
  static const Color softBg = AppColors.backgroundLight;

  static void show(
    BuildContext context, {
    required CalendarProvider cp,
    required int day,
    required String currentNote,
  }) {
    final noteController = TextEditingController(text: currentNote);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              'ویرایش خاطره',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 4),
            Text(
              cp.formatDate(day),
              style: TextStyle(fontSize: 13, color: textGrey),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: noteController,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: textDark),
              decoration: InputDecoration(
                hintText: 'متن جدید رو بنویس...',
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'انصراف',
                        style: TextStyle(color: textGrey, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (noteController.text.trim().isNotEmpty &&
                            noteController.text.trim() != currentNote) {
                          cp.updateNote(day, noteController.text.trim());
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();
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
                        'ذخیره 💕',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showDeleteDialog(context, cp, day);
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('حذف این خاطره'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteDialog(
      BuildContext context, CalendarProvider cp, int day) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: deepPink, size: 24),
            SizedBox(width: 8),
            Text(
              'حذف خاطره',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'این خاطره برای همیشه حذف میشه. مطمئنی؟',
          style: TextStyle(fontSize: 13, color: textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('بیخیال',
                style: TextStyle(color: textGrey, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              cp.deleteNote(day);
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: deepPink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('آره، حذف کن',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
