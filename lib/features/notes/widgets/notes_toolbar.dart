import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class NotesToolbar extends StatelessWidget {
  final bool isEditMode;
  final bool isDeleteMode;
  final VoidCallback onNewNote;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleDelete;
  final VoidCallback onConfirmDelete;
  final VoidCallback onToggleTick;
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
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color toolbarBg = appTheme?.cardBackground?.withOpacity(0.95) ??
        Colors.white.withValues(alpha: 0.9);
    final Color defaultButtonTextColor = appTheme?.textPrimary ??
        const Color(0xFF1A1A2E); // جایگزین قهوه‌ای قدیمی

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: toolbarBg, // 👈 پس‌زمینه نیمه‌شفاف با تم هماهنگ
      child: Row(
        children: [
          _toolButton(
            Icons.note_add,
            'جدید',
            onTap: onNewNote,
            defaultColor: defaultButtonTextColor,
          ),
          const SizedBox(width: 8),
          _toolButton(
            Icons.edit,
            'ویرایش',
            isActive: isEditMode,
            onTap: onToggleEdit,
            defaultColor: defaultButtonTextColor,
          ),
          const SizedBox(width: 8),
          _toolButton(
            isTickMode ? Icons.check_circle : Icons.check_circle_outline,
            'تیک',
            isActive: isTickMode,
            onTap: onToggleTick,
            defaultColor: defaultButtonTextColor,
          ),
          const Spacer(),
          if (isDeleteMode)
            _toolButton(
              Icons.check_rounded,
              'تأیید حذف',
              isRed: true,
              isActive: true,
              onTap: onConfirmDelete,
              defaultColor: defaultButtonTextColor,
            )
          else
            _toolButton(
              Icons.delete_outline,
              'حذف',
              isRed: true,
              onTap: onToggleDelete,
              defaultColor: defaultButtonTextColor,
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
    Color defaultColor = const Color(0xFF1A1A2E), // رنگ پیش‌فرض متناسب با تم
  }) {
    // رنگ آیکن و متن
    Color buttonColor;
    if (isActive) {
      buttonColor = AppColors.primaryDark; // بنفش/صورتی برند
    } else if (isRed) {
      buttonColor = Colors.red;
    } else {
      buttonColor = defaultColor; // پویا: در روشن تیره، در تاریک روشن
    }

    // رنگ پس‌زمینه دکمه (شفاف بر اساس وضعیت)
    Color? bgColor;
    if (isActive) {
      bgColor = AppColors.primaryDark.withOpacity(0.2);
    } else if (isRed) {
      bgColor = Colors.red.withOpacity(0.1);
    } else {
      bgColor = AppColors.primary.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: buttonColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 10,
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
