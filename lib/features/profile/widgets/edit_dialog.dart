import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

/// نمایش دیالوگ ویرایش پروفایل
///
/// [context] - BuildContext
/// [title] - عنوان فیلد (مثلاً "نام نمایشی")
/// [currentValue] - مقدار فعلی
/// [onSave] - callback بعد از ذخیره (مقدار جدید رو برمی‌گردونه)
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
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // آیکون ویرایش
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

              // عنوان
              Text(
                'ویرایش $title',
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // فیلد ورودی
              TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                obscureText: title == 'رمز عبور',
                style: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                decoration: InputDecoration(
                  hintText: '$title جدید',
                  filled: true,
                  fillColor: const Color(0xFFF5F0E8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),

              // دکمه‌ها
              Row(
                children: [
                  // انصراف
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'انصراف',
                        style: TextStyle(fontFamily: 'Vazir', fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ذخیره
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newValue = controller.text.trim();
                        if (newValue.isEmpty) return;

                        // 🔥 دکمه رو غیرفعال کن
                        Navigator.pop(dialogContext);

                        try {
                          await onSave(newValue);

                          // ✅ موفقیت
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
                          // ❌ خطا
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
