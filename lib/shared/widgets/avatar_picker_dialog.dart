import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/services/image_service.dart';

class AvatarPickerDialog {
  static Future<String?> show(BuildContext context,
      {bool hasImage = false}) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('انتخاب عکس پروفایل',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final path = await ImageService.pickFromGallery();
                        if (path != null && context.mounted)
                          Navigator.pop(context, path);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_library_rounded,
                                size: 44, color: AppColors.primary),
                            SizedBox(height: 10),
                            Text('گالری',
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final path = await ImageService.pickFromCamera();
                        if (path != null && context.mounted)
                          Navigator.pop(context, path);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                size: 44, color: AppColors.primary),
                            SizedBox(height: 10),
                            Text('دوربین',
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 🔥 دکمه حذف عکس
              if (hasImage) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context, 'delete'),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 20),
                    label: const Text('حذف عکس پروفایل',
                        style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 14,
                            color: Colors.red)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.red.withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Text('انصراف',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 15,
                          color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
