import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/period_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

void showSymptomSheet(
  BuildContext context, {
  Function(Map<String, dynamic>)? onSaved,
}) {
  final periodProvider = context.read<PeriodProvider>();
  int painLevel = 0;
  final List<String> symptoms = [];
  final List<String> symptomOptions = [
    'سردرد',
    'خستگی',
    'هوس شکلات',
    'کمردرد',
    'حساسیت',
    'تهوع',
    'بی‌حوصلگی',
    'جوش',
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // 👈 برای پس‌زمینه گرد
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      // 🔥 گرفتن تم
      final appTheme = Theme.of(context).extension<AppTheme>();
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // رنگ‌های پویا
      final Color bgColor = appTheme?.cardBackground ?? Colors.white;
      final Color textColor = appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
      final Color hintColor = appTheme?.textHint ?? const Color(0xFF8E8E98);
      final Color chipBg = isDark
          ? Colors.grey.shade800
          : Colors.grey.shade100; // پس‌زمینه چیپ‌های انتخاب‌نشده

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: bgColor, // 👈 پس‌زمینه اصلی
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                Text(
                  '✨ ثبت حال امروز',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor, // 👈
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'چقدر درد داری؟',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    color: textColor, // 👈
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return GestureDetector(
                      onTap: () => setSheetState(() => painLevel = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: painLevel == i
                              ? AppColors.primaryDark.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ['😊', '😐', '😟', '😖', '😫', '😵'][i],
                              style: TextStyle(
                                fontSize: painLevel == i ? 36 : 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                'هیچی',
                                'کم',
                                'متوسط',
                                'زیاد',
                                'خیلی',
                                'طاقت‌فرسا'
                              ][i],
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 9,
                                color: painLevel == i
                                    ? AppColors.primaryDark
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text(
                  'چه علائمی داری؟',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    color: textColor, // 👈
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: symptomOptions.map((s) {
                    final selected = symptoms.contains(s);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (selected) {
                            symptoms.remove(s);
                          } else {
                            symptoms.add(s);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryDark.withOpacity(0.15)
                              : chipBg, // 👈
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryDark
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 13,
                            color: selected
                                ? AppColors.primaryDark
                                : hintColor, // 👈
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (onSaved != null) {
                        onSaved({
                          'day': periodProvider.currentDay,
                          'pain': painLevel,
                          'mood': [
                            '😊',
                            '😐',
                            '😟',
                            '😖',
                            '😫',
                            '😵'
                          ][painLevel],
                          'symptoms': List.from(symptoms),
                          'date': 'همین الان',
                        });
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('✅ ثبت شد!',
                              style: TextStyle(fontFamily: 'Vazir')),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      'ذخیره 💾',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}
