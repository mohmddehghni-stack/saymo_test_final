import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/notes_manager_provider.dart';

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
    if (notes.isEmpty) {
      return const Center(
        child: Text('چیزی یادداشت نکردی امروز... ✍️',
            style: TextStyle(
                fontFamily: 'Vazir', fontSize: 13, color: Colors.black26)),
      );
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () {
            if (isTickMode) {
              onTick(note.id); // 🔥 فقط تیک
            } else if (isDeleteMode) {
              provider.toggleSelectForDelete(note.id); // 🔥 فقط انتخاب حذف
            } else if (isEditMode) {
              onEdit(note.id); // 🔥 فقط ویرایش
            }
          },
          child: _buildBubble(note),
        );
      },
    );
  }

  Widget _buildBubble(NoteItem note) {
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
                    onTick(note.id); // 🔥 تیک
                  } else if (isDeleteMode) {
                    provider.toggleSelectForDelete(note.id); // 🔥 انتخاب حذف
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
                  color: isDeleteMode
                      ? (isDeleteSelected ? Colors.red : Colors.grey)
                      : (isTickChecked ? AppColors.primaryDark : Colors.grey),
                  size: 22,
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEditingThis
                    ? AppColors.periodBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isEditingThis
                    ? Border.all(
                        color: AppColors.primaryDark.withValues(alpha: 0.3))
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
                        color: isTickChecked
                            ? const Color(
                                0xFFADADAD) // 🔥 رنگ خاکستری وقتی خط خورده
                            : const Color(0xFF3E2723), // رنگ اصلی
                        decoration:
                            isTickChecked ? TextDecoration.lineThrough : null,
                        decorationColor:
                            AppColors.primaryDark, // 🔥 رنگ خط (صورتی)
                        decorationThickness: 2.5, // 🔥 ضخامت خط (یکم کلفت‌تر)
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(note.time,
                        style: const TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 10,
                            color: Colors.grey)),
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
