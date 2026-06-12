import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/features/calendar/data/preset_moments.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter_application_1/shared/services/notification_service.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class MomentSwipeCards extends StatelessWidget {
  const MomentSwipeCards({super.key});

  static List<Widget> _buildCustomOptions(
    BuildContext context,
    void Function(void Function()) setSheetState,
    TextEditingController titleCtrl,
    void Function(String emoji) onEmojiChanged,
    String? selectedActivity,
    void Function(String title) onActivitySelected,
  ) {
    const Color primaryPink = Color(0xFFFE4773);
    const Color selectedCardBg = Color.fromARGB(75, 255, 255, 255);

    // 🔥 گرفتن AppTheme از context (متد استاتیک است ولی context دارد)
    final appTheme = Theme.of(context).extension<AppTheme>();
    final Color whiteBox = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF1A1A2E);

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
            color: isSelected ? selectedCardBg : whiteBox, // 👈 پویا
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
                  fontWeight: FontWeight.w500,
                  color: isSelected ? primaryPink : textColor, // 👈 پویا
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MomentProvider>();
    final cp = context.read<CalendarProvider>();
    final allMoments = mp.upcoming
        .where((m) => !m.isPrivate || m.userId == cp.userId)
        .toList();

    if (allMoments.isEmpty) return const SizedBox.shrink();

    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: allMoments.length,
        itemBuilder: (ctx, index) {
          final moment = allMoments[index];
          return _buildMomentCard(context, moment, mp,
              appTheme: appTheme, isDark: isDark);
        },
      ),
    );
  }

  static Widget _buildMomentCard(
    BuildContext context,
    Moment moment,
    MomentProvider mp, {
    AppTheme? appTheme,
    bool isDark = false,
  }) {
    // رنگ بنفش برند
    const Color purple = Color(0xFF862AF5);

    DateTime toMidnightUtc(Jalali j) {
      final d = j.toDateTime();
      return DateTime.utc(d.year, d.month, d.day);
    }

    final today = Jalali.now();
    final daysLeft =
        toMidnightUtc(moment.date).difference(toMidnightUtc(today)).inDays;

    String countdownStr;
    if (daysLeft == 0) {
      countdownStr = 'امروز';
    } else if (daysLeft == 1) {
      countdownStr = '۱ روز دیگر';
    } else if (daysLeft > 0) {
      countdownStr = '$daysLeft روز دیگر';
    } else {
      countdownStr = 'گذشت';
    }

    final dateStr =
        '${moment.date.day} ${_getMonthName(moment.date.month)} ${moment.date.year}';

    return GestureDetector(
      onTap: () => _showEditMomentSheet(context, moment),
      onLongPress: () => _showDeleteMomentDialog(context, moment),
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        decoration: BoxDecoration(
          // پس‌زمینه: در روشن بنفش کمرنگ، در تاریک رنگ کارت
          color: isDark
              ? (appTheme?.cardBackground ?? const Color(0xFF1E1E1E))
              : purple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withOpacity(0.15),
              ),
              child: Center(
                child: Text(moment.emoji, style: const TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    moment.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 10, color: purple.withOpacity(0.6)),
                      const SizedBox(width: 3),
                      Text(
                        dateStr,
                        style: TextStyle(
                            fontSize: 10, color: purple.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    countdownStr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────── ویرایش لحظه (با DraggableScrollableSheet) ──────
  static void _showEditMomentSheet(BuildContext context, Moment moment) {
    final titleController = TextEditingController(text: moment.title);
    String selectedCategory = moment.category;
    String selectedEmoji = moment.emoji;
    Jalali selectedDate = moment.date;
    bool isRecurring = moment.isRecurring;
    bool isPrivate = moment.isPrivate;
    TimeOfDay? selectedTime = moment.reminderTime;
    final momentProvider = context.read<MomentProvider>();

    final _searchController = TextEditingController();
    final Set<String> _selectedTitles = {};
    String? selectedActivity;

    const Color primaryPink = Color(0xFFFE4773);
    const Color primaryPurple = Color(0xFF862AF5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          // 🔥 دریافت تم
          final appTheme = Theme.of(context).extension<AppTheme>();
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final Color bgColor = appTheme?.cardBackground ?? Colors.white;
          final Color textColor =
              appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
          final Color hintColor = appTheme?.textHint ?? const Color(0xFF8E8E98);
          final Color whiteBox = appTheme?.cardBackground ?? Colors.white;

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (ctx, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('ویرایش لحظه ✨',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor)), // 👈 پویا
                      const SizedBox(height: 20),

                      // ─── نوع رویداد ───
                      _buildSectionTitle('نوع رویداد', primaryPink,
                          textColor: textColor),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildCategoryCard(
                            context, // 👈 اضافه شد
                            icon: Icons.event_available_rounded,
                            label: 'قرارها',
                            description: 'قرارهای عاشقانه، برنامه‌ها و...',
                            category: 'appointment',
                            selectedCategory: selectedCategory,
                            onTap: () => setSheetState(() {
                              selectedCategory = 'appointment';
                              selectedEmoji = '📅';
                              selectedActivity = null;
                              titleController.clear();
                            }),
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryCard(
                            context,
                            icon: Icons.celebration_rounded,
                            label: 'مناسبت‌ها',
                            description: 'تولد، سالگرد و...',
                            category: 'milestone',
                            selectedCategory: selectedCategory,
                            onTap: () => setSheetState(() {
                              selectedCategory = 'milestone';
                              selectedEmoji = '🎉';
                              selectedActivity = null;
                              titleController.clear();
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
                              selectedActivity = null;
                              titleController.clear();
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ─── فقط برای غیر مناسبت: مربع‌های فعالیت ───
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
                              (emoji) =>
                                  setSheetState(() => selectedEmoji = emoji),
                              selectedActivity,
                              (title) =>
                                  setSheetState(() => selectedActivity = title),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ─── عنوان رویداد ───
                      _buildSectionTitle('عنوان رویداد', primaryPink,
                          textColor: textColor),
                      const SizedBox(height: 8),
                      _buildTitleField(
                          titleController, primaryPink, hintColor, textColor,
                          boxColor: whiteBox), // 👈 اضافه کردن boxColor
                      const SizedBox(height: 16),

                      // ─── تاریخ رویداد ───
                      _buildSectionTitle('تاریخ رویداد', primaryPink,
                          textColor: textColor),
                      const SizedBox(height: 8),
                      _buildDatePickerCard(
                          selectedDate, primaryPink, textColor, hintColor,
                          () async {
                        final picked = await showPersianDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: Jalali(1400, 1, 1),
                          lastDate: Jalali(1410, 12, 29),
                          locale: const Locale('fa', 'IR'),
                        );
                        if (picked != null)
                          setSheetState(() => selectedDate = picked);
                      }, boxColor: whiteBox), // 👈 اضافه کردن boxColor
                      const SizedBox(height: 14),

                      // ─── زمان رویداد ───
                      _buildSectionTitle('زمان رویداد', primaryPink,
                          textColor: textColor),
                      const SizedBox(height: 8),
                      _buildTimePickerCard(
                          selectedTime, primaryPink, textColor, hintColor,
                          () async {
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
                      }, boxColor: whiteBox), // 👈 اضافه کردن boxColor
                      const SizedBox(height: 14),

                      // ─── تنظیمات ───
                      _buildSettingsBox(
                        isRecurring: isRecurring,
                        isPrivate: isPrivate,
                        onRecurringChanged: (v) =>
                            setSheetState(() => isRecurring = v),
                        onPrivateChanged: (v) =>
                            setSheetState(() => isPrivate = v),
                        primaryPink: primaryPink,
                        primaryPurple: primaryPurple,
                        textDark: textColor,
                        textGrey: hintColor,
                        boxColor: whiteBox, // 👈 اضافه شدن
                      ),
                      const SizedBox(height: 20),

                      // دکمه ذخیره
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isNotEmpty &&
                                moment.id != null) {
                              momentProvider.updateMoment(
                                id: moment.id!,
                                title: titleController.text.trim(),
                                date: selectedDate,
                                category: selectedCategory,
                                emoji: selectedEmoji,
                                isRecurring: isRecurring,
                                isPrivate: isPrivate,
                                reminderTime: selectedTime,
                              );

                              if (selectedTime != null) {
                                final scheduledDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime!.hour,
                                  selectedTime!.minute,
                                );
                                NotificationService.scheduleMomentNotification(
                                  id: moment.id!,
                                  title: titleController.text.trim(),
                                  body:
                                      '$selectedEmoji ${titleController.text.trim()}',
                                  scheduledDate: scheduledDate,
                                );
                              }

                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('ذخیره 💕',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // دکمه حذف
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showDeleteMomentDialog(context, moment),
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: primaryPink),
                          label: const Text('حذف این لحظه',
                              style:
                                  TextStyle(color: primaryPink, fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: primaryPink.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
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
      ),
    );
  }

// ────────── توابع کمکی UI ──────────

  static Widget _buildSectionTitle(String title, Color dotColor,
      {Color textColor = const Color(0xFF1A1A2E)}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  static Widget _buildCategoryCard(
    BuildContext context, {
    // 👈 context اجباری شد
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
              color: isSelected
                  ? const Color.fromARGB(75, 255, 255, 255)
                  : cardBgColor, // 👈 پویا
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFFFE4773) : Colors.grey.shade200,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFFFE4773).withOpacity(0.15)
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
                    Icon(icon, size: 32, color: const Color(0xFFFE4773)),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFFFE4773)
                            : const Color(0xFF8E8E98),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? const Color(0xFFFE4773).withOpacity(0.7)
                            : const Color(0xFF8E8E98).withOpacity(0.5),
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
                          color: Color(0xFFFE4773),
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

  static Widget _buildTitleField(
      TextEditingController controller, Color primary, Color grey, Color dark,
      {Color boxColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: boxColor, // 👈
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(fontSize: 14, color: dark),
        decoration: InputDecoration(
          hintText: 'مثلاً: قرار کافه، رفتن به سینما...',
          hintStyle: TextStyle(color: grey.withOpacity(0.5), fontSize: 13),
          filled: true,
          fillColor: boxColor, // 👈
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  static Widget _buildDatePickerCard(
      Jalali date, Color primary, Color dark, Color grey, VoidCallback onTap,
      {Color boxColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: boxColor, // 👈
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
            Icon(Icons.calendar_today, size: 18, color: primary),
            const SizedBox(width: 8),
            Text(
              '${date.day} ${_getMonthName(date.month)} ${date.year}',
              style: TextStyle(fontSize: 13, color: dark),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTimePickerCard(TimeOfDay? time, Color primary, Color dark,
      Color grey, VoidCallback onTap,
      {Color boxColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: boxColor, // 👈
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
            Icon(Icons.access_time, size: 18, color: primary),
            const SizedBox(width: 8),
            Text(
              time != null
                  ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                  : 'انتخاب زمان (اختیاری)',
              style: TextStyle(
                fontSize: 13,
                color: time != null ? dark : grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSettingsBox({
    required bool isRecurring,
    required bool isPrivate,
    required ValueChanged<bool> onRecurringChanged,
    required ValueChanged<bool> onPrivateChanged,
    required Color primaryPink,
    required Color primaryPurple,
    required Color textDark,
    required Color textGrey,
    Color boxColor = Colors.white, // 👈 پارامتر جدید
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: boxColor, // 👈
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.repeat_rounded,
                      size: 20, color: Color(0xFF862AF5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تکرار هر سال',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textDark)),
                      const SizedBox(height: 2),
                      Text('تکرار هرسال در همین موقع',
                          style: TextStyle(fontSize: 11, color: textGrey)),
                    ],
                  ),
                ),
                Switch(
                  value: isRecurring,
                  onChanged: onRecurringChanged,
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
              color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      size: 20, color: Color(0xFF862AF5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('فقط برای خودم',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textDark)),
                      const SizedBox(height: 2),
                      Text('این عنوان فقط برای من نمایش داده بشه',
                          style: TextStyle(fontSize: 11, color: textGrey)),
                    ],
                  ),
                ),
                Switch(
                  value: isPrivate,
                  onChanged: onPrivateChanged,
                  activeColor: primaryPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showDeleteMomentDialog(BuildContext context, Moment moment) {
    if (moment.id == null) return;
    final appTheme = Theme.of(context).extension<AppTheme>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: appTheme?.cardBackground ?? Colors.white,
        title: Row(children: [
          const Icon(Icons.delete_outline, color: Color(0xFFE8456B), size: 24),
          const SizedBox(width: 8),
          Text('حذف لحظه',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appTheme?.textPrimary ?? const Color(0xFF1A1A2E))),
        ]),
        content: Text('«${moment.title}» برای همیشه حذف میشه. مطمئنی؟',
            style: TextStyle(
                fontSize: 13,
                color: appTheme?.textHint ?? const Color(0xFF8E8E98))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('بیخیال',
                  style: TextStyle(
                      color: appTheme?.textHint ?? const Color(0xFF8E8E98),
                      fontSize: 13))),
          ElevatedButton(
            onPressed: () async {
              await context.read<MomentProvider>().deleteMoment(moment.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8456B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('آره، حذف کن',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  static Widget _buildCategoryChip(String emoji, String label, String category,
      String selected, VoidCallback onTap) {
    final isSelected = selected == category;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.transparent),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFF8E8E98)))
          ]),
        ),
      ),
    );
  }

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
}
