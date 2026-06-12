import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import '../sheets/edit_note_sheet.dart';
import '../sheets/note_detail_dialog.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class NotesSection extends StatelessWidget {
  final CalendarProvider cp;

  const NotesSection({super.key, required this.cp});

  static const Color primaryPink = AppColors.primary;
  static const Color deepPink = Color(0xFFE8456B);
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
    // 🔥 گرفتن تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cp.isLoading) return _buildShimmerNotes(isDark);

    final allNotes = cp.savedNotesWithFullKey;
    if (allNotes.isEmpty) return _buildEmptyState(appTheme, isDark);

    final sortedKeys = allNotes.keys.toList()..sort((a, b) => b.compareTo(a));

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
              Text(
                'یادداشت',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: appTheme?.textPrimary ?? const Color(0xFF1A1A2E), // 👈
                ),
              ),
              const Spacer(),
              Text(
                '${sortedKeys.length} یادداشت',
                style: TextStyle(
                  fontSize: 11,
                  color: appTheme?.textHint ?? const Color(0xFF8E8E98), // 👈
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sortedKeys.map((key) {
            final dayNotes = allNotes[key];
            if (dayNotes == null || dayNotes.isEmpty)
              return const SizedBox.shrink();

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
                    context,
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
                    context,
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

  Widget _buildNoteCard(
    BuildContext context, {
    required String dateStr,
    required String note,
    required bool isMyNote,
    required bool isSelected,
    required int day,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isMyNote ? primaryPink : partnerBlue;
    final Color bgColor = appTheme?.cardBackground ?? const Color(0xFFFFFFFF);
    final Color mainTextColor =
        appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
    final Color subTextColor = appTheme?.textHint ?? const Color(0xFF8E8E98);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
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
                          color: subTextColor.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: TextStyle(
                            fontSize: isSelected ? 10 : 9, color: subTextColor),
                      ),
                      const Spacer(),
                      if (isMyNote)
                        Icon(Icons.edit_rounded,
                            size: 14, color: subTextColor.withOpacity(0.4)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: isSelected ? 13 : 11.5,
                      color: isSelected ? mainTextColor : subTextColor,
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

  Widget _buildShimmerNotes(bool isDark) {
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
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
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
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppTheme? appTheme, bool isDark) {
    final subTextColor = appTheme?.textHint ?? const Color(0xFF8E8E98);
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
              fontSize: 14, fontWeight: FontWeight.w500, color: subTextColor),
        ),
        const SizedBox(height: 4),
        Text(
          'با + یه خاطره قشنگ ثبت کن ✨',
          style: TextStyle(fontSize: 12, color: subTextColor.withOpacity(0.6)),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, CalendarProvider cp, int day) {
    showDialog(
      context: context,
      builder: (ctx) {
        final appTheme = Theme.of(context).extension<AppTheme>();
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: appTheme?.cardBackground ?? Colors.white,
          title: Row(
            children: [
              const Icon(Icons.delete_outline, color: deepPink, size: 24),
              const SizedBox(width: 8),
              Text('حذف خاطره',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: appTheme?.textPrimary ?? const Color(0xFF1A1A2E))),
            ],
          ),
          content: Text(
            'این یادداشت برای همیشه حذف میشه. مطمئنی؟',
            style: TextStyle(
                fontSize: 13,
                color: appTheme?.textHint ?? const Color(0xFF8E8E98)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('بیخیال',
                  style: TextStyle(
                      fontSize: 13,
                      color: appTheme?.textHint ?? const Color(0xFF8E8E98))),
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
        );
      },
    );
  }
}
