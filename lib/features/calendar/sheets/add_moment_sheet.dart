import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/features/calendar/data/preset_moments.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/shared/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/core/theme/app_theme.dart';

class AddMomentSheet {
  static const Color primaryPink = Color(0xFFFE4773); // رنگ اصلی جدید
  static const Color selectedCardBg =
      Color.fromARGB(255, 255, 244, 244); // جایگزین FDF4F5
  static const Color softBg =
      Color(0xFFFDF4F5); // می‌تونی برای جاهای دیگه هم استفاده کنی
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8E8E98);
  static const Color primaryPurple = Color(0xFF862AF5); // بنفش برند

  static String _getMonthName(int month) {
    const names = [
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
    return names[month];
  }

  static void show(BuildContext context, MomentProvider momentProvider) {
    final titleController = TextEditingController();
    final _searchController = TextEditingController();
    String selectedCategory = 'appointment'; // 🔥 تغییر نوع
    String selectedEmoji = '🎉';
    final Set<String> _selectedTitles = {};
    Jalali selectedDate = Jalali.now();
    bool isRecurring = false;
    bool isPrivate = false;
    String? selectedActivity;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // 🔥 گرفتن تم و وضعیت در builder
        final appTheme = Theme.of(context).extension<AppTheme>();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final mp = context.read<MomentProvider>();
            // رنگ‌های تطبیق‌یافته برای ویجت‌های داخلی
            final Color bgColor = appTheme?.cardBackground ?? cardBg;
            final Color textColor = appTheme?.textPrimary ?? textDark;
            final Color hintColor = appTheme?.textHint ?? textGrey;
            final Color whiteBox = appTheme?.cardBackground ?? Colors.white;

            return Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: bgColor, // پس‌زمینه اصلی
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 36,
                        height: 3,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    Text('ثبت لحظه جدید ✨',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 20),

                    // ─── عنوان با نقطه ───
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryPink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نوع رویداد',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // کارت‌های انتخاب نوع رویداد
                    Row(
                      children: [
                        _buildCategoryCard(
                          context,
                          icon: Icons.event_available_rounded,
                          label: 'قرارها',
                          description: 'قرارهای عاشقانه، برنامه‌ها و...',
                          category: 'appointment',
                          selectedCategory: selectedCategory,
                          onTap: () => setSheetState(() {
                            selectedCategory = 'appointment';
                            selectedEmoji = '📅';
                            selectedActivity = null;
                            _selectedTitles.clear();
                            _searchController.clear();
                          }),
                        ),
                        const SizedBox(width: 10),
                        _buildCategoryCard(
                          context,
                          icon: Icons.card_giftcard,
                          label: 'مناسبت‌ها',
                          description: 'تولد، سالگرد و...',
                          category: 'milestone',
                          selectedCategory: selectedCategory,
                          onTap: () => setSheetState(() {
                            selectedCategory = 'milestone';
                            selectedEmoji = '🎉';
                            _selectedTitles.clear();
                            _searchController.clear();
                          }),
                        ),
                        const SizedBox(width: 10),
                        _buildCategoryCard(
                          context,
                          icon: Icons.favorite_rounded,
                          label: 'اولین‌ها',
                          description: 'نقاط عطف رابطه',
                          category: 'first',
                          selectedCategory: selectedCategory,
                          onTap: () => setSheetState(() {
                            selectedCategory = 'first';
                            selectedEmoji = '💖';
                            _selectedTitles.clear();
                            _searchController.clear();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 14),
                    if (selectedCategory != 'milestone') ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'چی رو میخوای ثبت کنی؟',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          children: _buildCustomOptions(
                            context,
                            setSheetState,
                            titleController,
                            (emoji) => selectedEmoji = emoji,
                            selectedActivity,
                            (title) => selectedActivity = title,
                            whiteBox, // بدون نام، فقط مقدار
                            textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryPink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'عنوان رویداد',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: whiteBox,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: primaryPink.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: titleController,
                          autofocus: true,
                          style: TextStyle(fontSize: 14, color: textColor),
                          decoration: InputDecoration(
                            hintText: 'مثلاً: قرار کافه، رفتن به سینما...',
                            hintStyle: TextStyle(
                              color: hintColor.withOpacity(0.5),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: whiteBox,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ─── زمان رویداد ───
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryPink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'زمان رویداد',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await _showJalaliDatePicker(
                                context: context,
                                initialDate: selectedDate,
                              );
                              if (picked != null)
                                setSheetState(() => selectedDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: whiteBox,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: primaryPink),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                                      style: TextStyle(
                                          fontSize: 13, color: textColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ??
                                    const TimeOfDay(hour: 9, minute: 0),
                                builder: (context, child) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: true),
                                    child: child!,
                                  ),
                                ),
                              );
                              if (time != null)
                                setSheetState(() => selectedTime = time);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: whiteBox,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 18, color: primaryPink),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedTime != null
                                          ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                          : 'انتخاب زمان',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: selectedTime != null
                                            ? textColor
                                            : hintColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ─── کادر یکپارچه تنظیمات با توضیحات ───
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: whiteBox,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: primaryPurple.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.repeat_rounded,
                                    size: 20,
                                    color: primaryPurple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تکرار هر سال',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'تکرار هرسال در همین موقع',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isRecurring,
                                  onChanged: (v) =>
                                      setSheetState(() => isRecurring = v),
                                  activeColor: primaryPurple,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 56,
                            endIndent: 16,
                            color: Colors.grey.shade100,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: primaryPurple.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                    color: primaryPurple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'فقط برای خودم',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'این عنوان فقط برای من نمایش داده بشه',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isPrivate,
                                  onChanged: (v) =>
                                      setSheetState(() => isPrivate = v),
                                  activeColor: primaryPurple,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // دکمه ثبت
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          // (منطق ثبت بدون تغییر)
                          final mp = context.read<MomentProvider>();
                          mp.init();
                          await Future.delayed(
                              const Duration(milliseconds: 300));

                          if (selectedCategory == 'milestone' &&
                              _selectedTitles.isNotEmpty) {
                            for (final title in _selectedTitles) {
                              final preset = PresetMoments.milestones
                                  .firstWhere((p) => p['title'] == title);
                              final momentId = await mp.addMoment(
                                title: title,
                                date: selectedDate,
                                startDate: Jalali.now(),
                                category: selectedCategory,
                                emoji: preset['emoji'] ?? '💎',
                                isRecurring: isRecurring,
                                isPrivate: isPrivate,
                                reminderTime: selectedTime,
                              );
                              if (selectedTime != null && momentId != null) {
                                final scheduledDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime!.hour,
                                  selectedTime!.minute,
                                );
                                NotificationService.scheduleMomentNotification(
                                  id: momentId,
                                  title: title,
                                  body: '${preset['emoji']} $title',
                                  scheduledDate: scheduledDate,
                                );
                              }
                            }
                            Navigator.pop(ctx);
                            HapticFeedback.mediumImpact();
                          } else if (titleController.text.trim().isNotEmpty) {
                            final momentId = await mp.addMoment(
                              title: titleController.text.trim(),
                              date: selectedDate,
                              startDate: Jalali.now(),
                              category: selectedCategory,
                              emoji: selectedEmoji,
                              isRecurring: isRecurring,
                              isPrivate: isPrivate,
                            );
                            if (selectedTime != null && momentId != null) {
                              final scheduledDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime!.hour,
                                selectedTime!.minute,
                              );
                              NotificationService.scheduleMomentNotification(
                                id: momentId,
                                title: titleController.text.trim(),
                                body:
                                    '$selectedEmoji ${titleController.text.trim()}',
                                scheduledDate: scheduledDate,
                              );
                            }
                            Navigator.pop(ctx);
                            HapticFeedback.mediumImpact();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: Text(
                            selectedCategory == 'milestone'
                                ? 'ثبت ${_selectedTitles.length} لحظه ✨'
                                : 'ثبت لحظه ✨',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static List<Widget> _buildCustomOptions(
    BuildContext context,
    void Function(void Function()) setSheetState,
    TextEditingController titleCtrl,
    void Function(String emoji) onEmojiChanged,
    String? selectedActivity,
    void Function(String title) onActivitySelected,
    Color whiteBox, // بدون required
    Color textColor, // بدون required
  ) {
    final options = [
      {'icon': Icons.auto_awesome, 'title': 'سفارشی', 'emoji': '✨'},
      {'icon': Icons.local_movies, 'title': 'سینما', 'emoji': '🎬'},
      {'icon': Icons.park, 'title': 'پارک', 'emoji': '🌳'},
      {'icon': Icons.local_cafe, 'title': 'کافه', 'emoji': '☕'},
      {'icon': Icons.restaurant, 'title': 'رستوران', 'emoji': '🍽️'},
      {'icon': Icons.shopping_bag, 'title': 'خرید', 'emoji': '🛍️'},
      {'icon': Icons.directions_walk, 'title': 'پیاده‌روی', 'emoji': '🚶'},
      {'icon': Icons.fitness_center, 'title': 'ورزش', 'emoji': '🏋️'},
      {'icon': Icons.flight, 'title': 'مسافرت', 'emoji': '✈️'},
    ];

    return options.map((opt) {
      final isSelected = opt['title'] == selectedActivity;
      return GestureDetector(
        onTap: () {
          setSheetState(() {
            if (opt['title'] != 'سفارشی') {
              titleCtrl.text = opt['title'] as String;
            } else {
              titleCtrl.clear();
            }
            onEmojiChanged(opt['emoji'] as String);
            onActivitySelected(opt['title'] as String);
          });
        },
        child: Container(
          width: 60,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedCardBg : whiteBox,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                opt['icon'] as IconData,
                size: 22,
                color: isSelected ? primaryPink : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                opt['title'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? primaryPink : textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ... بقیه متدها بدون تغییر
  static Future<Jalali?> _showJalaliDatePicker({
    required BuildContext context,
    required Jalali initialDate,
  }) async {
    final now = Jalali.now();
    final firstDate = Jalali(now.year - 2, 1, 1);
    final lastDate = Jalali(now.year + 5, 12, 29);

    return showDialog<Jalali>(
      context: context,
      builder: (context) => _JalaliDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

// متد _buildCategoryCard
  static Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required String category,
    required String selectedCategory,
    required VoidCallback onTap,
  }) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final Color cardBgColor = appTheme?.cardBackground ?? Colors.white;
    final isSelected = selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 145,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedCardBg : cardBgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? primaryPink : Colors.grey.shade200,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? primaryPink.withOpacity(0.15)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: primaryPink),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? primaryPink : textGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? primaryPink.withOpacity(0.8)
                            : textGrey.withOpacity(0.5),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryPink,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================
// 🔥 دیالوگ تقویم شمسی
// =============================================
class _JalaliDatePickerDialog extends StatefulWidget {
  final Jalali initialDate;
  final Jalali firstDate;
  final Jalali lastDate;

  const _JalaliDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_JalaliDatePickerDialog> createState() =>
      _JalaliDatePickerDialogState();
}

class _JalaliDatePickerDialogState extends State<_JalaliDatePickerDialog> {
  late Jalali _selectedDate;
  late int _viewYear;
  late int _viewMonth;
  late PageController _pageController;

  static const Color primaryPink = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final now = Jalali.now();
    _viewYear = now.year;
    _viewMonth = now.month;
    final initialTotalMonth =
        widget.initialDate.year * 12 + widget.initialDate.month;
    final nowTotalMonth = now.year * 12 + now.month;
    final pageOffset = nowTotalMonth - initialTotalMonth;
    _pageController = PageController(initialPage: 12 + pageOffset);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Jalali _getMonthDate(int page) {
    final baseMonth = widget.initialDate.year * 12 + widget.initialDate.month;
    final totalMonth = baseMonth + (page - 12);
    final year = totalMonth ~/ 12;
    final month = (totalMonth % 12);
    return Jalali(year, month == 0 ? 12 : month, 1);
  }

  bool _isDateDisabled(Jalali date) {
    return date.toDateTime().isBefore(
              widget.firstDate.toDateTime().subtract(const Duration(days: 1)),
            ) ||
        date.toDateTime().isAfter(widget.lastDate.toDateTime());
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF333333);
    final Color softBg =
        (appTheme?.cardBackground ?? Colors.white).withOpacity(0.04);
    // از primaryPink ثابت استفاده می‌کنیم.

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: bgColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(textColor, bgColor),
            const SizedBox(height: 16),
            _buildWeekDays(),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  final date = _getMonthDate(page);
                  setState(() {
                    _viewYear = date.year;
                    _viewMonth = date.month;
                  });
                },
                itemBuilder: (context, page) =>
                    _buildCalendarGrid(page, textColor),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color bgColor) {
    const monthNames = [
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
      'اسفند'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                color: primaryPink, size: 22),
          ),
        ),
        Column(
          children: [
            Text(
              monthNames[_viewMonth],
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              '$_viewYear',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 12,
                  color: textColor.withOpacity(0.6)),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: primaryPink, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    const days = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          final isFriday = day == 'ج';
          return SizedBox(
            width: 36,
            child: Center(
              child: Text(day,
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isFriday
                        ? primaryPink.withOpacity(0.7)
                        : Colors.grey.shade500,
                  )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(int page, Color textColor) {
    final monthDate = _getMonthDate(page);
    final year = monthDate.year;
    final month = monthDate.month;
    final daysInMonth = monthDate.monthLength;
    final firstDay = Jalali(year, month, 1).weekDay;
    final startOffset = firstDay == 7 ? 6 : firstDay - 1;
    final today = Jalali.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: 42,
        itemBuilder: (context, index) {
          final dayNumber = index - startOffset + 1;
          if (dayNumber < 1 || dayNumber > daysInMonth) {
            return const SizedBox.shrink();
          }

          final date = Jalali(year, month, dayNumber);
          final isSelected = date == _selectedDate;
          final isToday = date == today;
          final isDisabled = _isDateDisabled(date);

          return GestureDetector(
            onTap:
                isDisabled ? null : () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryPink
                    : isToday
                        ? primaryPink.withOpacity(0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isSelected
                    ? Border.all(
                        color: primaryPink.withOpacity(0.5), width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text('$dayNumber',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.w400,
                      color: isDisabled
                          ? Colors.grey.shade300
                          : isSelected
                              ? Colors.white
                              : isToday
                                  ? primaryPink
                                  : textColor,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف',
                style: TextStyle(fontFamily: 'Vazir', fontSize: 15)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context, _selectedDate),
            child: Text(
              '${_selectedDate.day} ${AddMomentSheet._getMonthName(_selectedDate.month)} ${_selectedDate.year}',
              style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
