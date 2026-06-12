import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // اضافه شد

Future<void> showEditDialog({
  required BuildContext context,
  required String title,
  required String currentValue,
  required Future<void> Function(String) onSave,
}) async {
  final controller = TextEditingController(
    text: currentValue.isEmpty ? '' : currentValue,
  );

  return showDialog(
    context: context,
    builder: (dialogContext) {
      final appTheme = Theme.of(context).extension<AppTheme>();
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: appTheme?.cardBackground ?? Colors.white, // 👈
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ویرایش $title',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appTheme?.textPrimary ?? AppColors.textPrimary, // 👈
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                obscureText: title == 'رمز عبور',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 14,
                  color: appTheme?.textPrimary, // 👈 متن ورودی
                ),
                decoration: InputDecoration(
                  hintText: '$title جدید',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white10
                      : const Color(0xFFF5F0E8), // 👈 پس‌زمینه فیلد
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor:
                            appTheme?.textHint ?? Colors.grey, // 👈
                      ),
                      child: const Text(
                        'انصراف',
                        style: TextStyle(fontFamily: 'Vazir', fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newValue = controller.text.trim();
                        if (newValue.isEmpty) return;

                        Navigator.pop(dialogContext);

                        try {
                          await onSave(newValue);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ $title با موفقیت ویرایش شد!',
                                  style: const TextStyle(fontFamily: 'Vazir'),
                                ),
                                backgroundColor: AppColors.primaryDark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '❌ خطا در ویرایش $title',
                                  style: const TextStyle(fontFamily: 'Vazir'),
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'ذخیره',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
