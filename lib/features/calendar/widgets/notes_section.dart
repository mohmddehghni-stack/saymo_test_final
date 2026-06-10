import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import '../sheets/edit_note_sheet.dart';
import '../sheets/note_detail_dialog.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class NotesSection extends StatelessWidget {
  final CalendarProvider cp;

  const NotesSection({super.key, required this.cp});

  static const Color primaryPink = AppColors.primary;
  static const Color deepPink = Color(0xFFE8456B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8E8E98);
  static const Color partnerBlue = Color(0xFF5B8DEF);

  static const List<String> _monthNames = [
    '',
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  @override
  Widget build(BuildContext context) {
    if (cp.isLoading) return _buildShimmerNotes();

    // 🔥 از تمام یادداشت‌های ثبت‌شده (همه ماه‌ها) استفاده کن
    final allNotes = cp.savedNotesWithFullKey;
    if (allNotes.isEmpty) return _buildEmptyState();

    // 🔥 کلیدها را بر اساس تاریخ (جدیدترین اول) مرتب می‌کنیم
    final sortedKeys = allNotes.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // کلیدها به فرمت YYYY-MM-DD هستند

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient:
                      const LinearGradient(colors: [deepPink, primaryPink]),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'خاطرات',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: textDark),
              ),
              const Spacer(),
              Text(
                '${sortedKeys.length} خاطره',
                style: TextStyle(fontSize: 11, color: textGrey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sortedKeys.map((key) {
            final dayNotes = allNotes[key];
            if (dayNotes == null || dayNotes.isEmpty)
              return const SizedBox.shrink();

            // 🔥 استخراج تاریخ شمسی از کلید (مثلاً ۱۴۰۵-۰۳-۱۹)
            String dateStr = '';
            int? day;
            try {
              final parts = key.split('-');
              if (parts.length == 3) {
                final y = int.parse(parts[0]);
                final m = int.parse(parts[1]);
                final d = int.parse(parts[2]);
                dateStr = '$d ${_monthNames[m]} $y';
                day = d;
              }
            } catch (_) {
              return const SizedBox.shrink();
            }

            final isSelected = day == cp.selectedDay;

            return Column(
              children: [
                if (dayNotes.containsKey(cp.userId))
                  _buildNoteCard(
                    dateStr: dateStr,
                    note: dayNotes[cp.userId!]!['note']?.toString() ?? '',
                    isMyNote: true,
                    isSelected: isSelected,
                    day: day ?? 0,
                    onTap: () => EditNoteSheet.show(
                      context,
                      cp: cp,
                      day: day ?? 0,
                      currentNote:
                          dayNotes[cp.userId!]!['note']?.toString() ?? '',
                    ),
                    onLongPress: () => _showDeleteDialog(context, cp, day ?? 0),
                  ),
                if (dayNotes.containsKey(cp.partnerId))
                  _buildNoteCard(
                    dateStr: dateStr,
                    note: dayNotes[cp.partnerId!]!['note']?.toString() ?? '',
                    isMyNote: false,
                    isSelected: isSelected,
                    day: day ?? 0,
                    onTap: () => NoteDetailDialog.show(
                      context,
                      dateStr: dateStr,
                      note: dayNotes[cp.partnerId!]!['note']?.toString() ?? '',
                      isMyNote: false,
                    ),
                    onLongPress: null,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoteCard({
    required String dateStr,
    required String note,
    required bool isMyNote,
    required bool isSelected,
    required int day,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final color = isMyNote ? primaryPink : partnerBlue;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            width: isSelected ? 1.2 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: isSelected ? 38 : 32,
              height: isSelected ? 38 : 32,
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
                  size: isSelected ? 16 : 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isMyNote ? 'یادداشت من' : 'پارتنر',
                        style: TextStyle(
                          fontSize: isSelected ? 12 : 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: textGrey.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: TextStyle(
                            fontSize: isSelected ? 10 : 9, color: textGrey),
                      ),
                      const Spacer(),
                      if (isMyNote)
                        Icon(Icons.edit_rounded,
                            size: 14, color: textGrey.withOpacity(0.4)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: isSelected ? 13 : 11.5,
                      color: isSelected ? textDark : textGrey,
                      height: 1.35,
                    ),
                    maxLines: isSelected ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerNotes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 3; i++) ...[
            Container(
              height: 72,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primaryPink.withOpacity(0.1),
                primaryPink.withOpacity(0.05)
              ],
            ),
          ),
          child:
              const Center(child: Text('💌', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 12),
        Text(
          'هنوز خاطره‌ای ثبت نشده',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textGrey),
        ),
        const SizedBox(height: 4),
        Text(
          'با + یه خاطره قشنگ ثبت کن ✨',
          style: TextStyle(fontSize: 12, color: textGrey.withOpacity(0.6)),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, CalendarProvider cp, int day) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: deepPink, size: 24),
            SizedBox(width: 8),
            Text('حذف خاطره',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
