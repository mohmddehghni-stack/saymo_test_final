import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/notes_manager_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class NotesMyList extends StatelessWidget {
  final List<NoteItem> notes;
  final bool isTickMode;
  final bool isEditMode;
  final bool isDeleteMode;
  final int? editingId;
  final Function(int) onTick;
  final Function(int) onEdit;
  final NotesManagerProvider provider;

  const NotesMyList({
    super.key,
    required this.notes,
    required this.isTickMode,
    required this.isEditMode,
    required this.isDeleteMode,
    required this.editingId,
    required this.onTick,
    required this.onEdit,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های تطبیق‌یافته
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF3E2723);
    final Color hintColor = appTheme?.textHint ?? Colors.grey;
    final Color emptyTextColor = appTheme?.textHint ?? Colors.black26;
    final Color checkedTextColor = const Color(0xFFADADAD); // ثابت می‌ماند
    final Color unselectedIconColor = hintColor; // جایگزین Colors.grey
    final Color editHighlightBg = isDark
        ? AppColors.primaryDark.withOpacity(0.08)
        : AppColors.periodBackground;

    if (notes.isEmpty) {
      return Center(
        child: Text(
          'چیزی یادداشت نکردی امروز... ✍️',
          style: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 13,
            color: emptyTextColor, // 👈 جایگزین Colors.black26
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () {
            if (isTickMode) {
              onTick(note.id);
            } else if (isDeleteMode) {
              provider.toggleSelectForDelete(note.id);
            } else if (isEditMode) {
              onEdit(note.id);
            }
          },
          child: _buildBubble(
            note,
            textColor: textColor,
            hintColor: hintColor,
            checkedTextColor: checkedTextColor,
            unselectedIconColor: unselectedIconColor,
            editHighlightBg: editHighlightBg,
          ),
        );
      },
    );
  }

  Widget _buildBubble(
    NoteItem note, {
    required Color textColor,
    required Color hintColor,
    required Color checkedTextColor,
    required Color unselectedIconColor,
    required Color editHighlightBg,
  }) {
    final isTickChecked = note.isChecked;
    final isDeleteSelected = note.isSelectedForDelete;
    final showCheckbox = isTickMode || isDeleteMode;
    final isEditingThis = editingId == note.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCheckbox)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () {
                  if (isTickMode) {
                    onTick(note.id);
                  } else if (isDeleteMode) {
                    provider.toggleSelectForDelete(note.id);
                  }
                },
                child: Icon(
                  isDeleteMode
                      ? (isDeleteSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                      : (isTickChecked
                          ? Icons.check_circle
                          : Icons.check_circle_outline),
                  // رنگ آیکن
                  color: isDeleteMode
                      ? (isDeleteSelected ? Colors.red : unselectedIconColor)
                      : (isTickChecked
                          ? AppColors.primaryDark
                          : unselectedIconColor),
                  size: 22,
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEditingThis ? editHighlightBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isEditingThis
                    ? Border.all(color: AppColors.primaryDark.withOpacity(0.3))
                    : null,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      note.text,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        // رنگ متن: اگر تیک خورده = خط‌خورده خاکستری، وگرنه متن اصلی
                        color: isTickChecked ? checkedTextColor : textColor,
                        decoration:
                            isTickChecked ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.primaryDark,
                        decorationThickness: 2.5,
                      ),
                    ),
                    const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }
}
