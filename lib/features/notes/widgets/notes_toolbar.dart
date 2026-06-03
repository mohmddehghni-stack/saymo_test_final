import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class NotesToolbar extends StatelessWidget {
  final bool isEditMode;
  final bool isDeleteMode;
  final VoidCallback onNewNote;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleDelete; // 🔥 فعال کردن حالت حذف
  final VoidCallback onConfirmDelete; // 🔥 تأیید حذف تیک‌دارها
  final VoidCallback onToggleTick; // 🔥 فعال کردن حالت تیک (بدون حذف)
  final bool isTickMode;

  const NotesToolbar({
    super.key,
    required this.isEditMode,
    required this.isDeleteMode,
    required this.onNewNote,
    required this.onToggleEdit,
    required this.onToggleDelete,
    required this.onConfirmDelete,
    required this.onToggleTick,
    required this.isTickMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white.withValues(alpha: 0.9),
      child: Row(
        children: [
          // ➕ جدید
          _toolButton(Icons.note_add, 'جدید', onTap: onNewNote),
          const SizedBox(width: 8),

          // ✏️ ویرایش
          _toolButton(
            Icons.edit,
            'ویرایش',
            isActive: isEditMode,
            onTap: onToggleEdit,
          ),
          const SizedBox(width: 8),

          // ✅ تیک (خط زدن)
          _toolButton(
            isTickMode ? Icons.check_circle : Icons.check_circle_outline,
            'تیک',
            isActive: isTickMode,
            onTap: onToggleTick,
          ),
          const Spacer(),

          // 🗑️ حذف (یا تأیید حذف)
          if (isDeleteMode)
            _toolButton(
              Icons.check_rounded,
              'تأیید حذف',
              isRed: true,
              isActive: true,
              onTap: onConfirmDelete,
            )
          else
            _toolButton(
              Icons.delete_outline,
              'حذف',
              isRed: true,
              onTap: onToggleDelete,
            ),
        ],
      ),
    );
  }

  Widget _toolButton(
    IconData icon,
    String label, {
    bool isRed = false,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryDark.withValues(alpha: 0.2)
              : isRed
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? AppColors.primaryDark
                  : (isRed ? Colors.red : const Color(0xFF5D4037)),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 10,
                color: isActive
                    ? AppColors.primaryDark
                    : (isRed ? Colors.red : const Color(0xFF5D4037)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
