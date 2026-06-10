import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/features/calendar/data/preset_moments.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter_application_1/shared/services/notification_service.dart';

class MomentSwipeCards extends StatelessWidget {
  const MomentSwipeCards({super.key});

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MomentProvider>();
    final cp = context.read<CalendarProvider>();
    final allMoments = mp.upcoming
        .where((m) => !m.isPrivate || m.userId == cp.userId)
        .toList();

    if (allMoments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: allMoments.length,
        itemBuilder: (ctx, index) {
          final moment = allMoments[index];
          return _buildMomentCard(context, moment, mp);
        },
      ),
    );
  }

  static Widget _buildMomentCard(
      BuildContext context, Moment moment, MomentProvider mp) {
    final countdownText = mp.countdownText(moment);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 3;

    return GestureDetector(
      onTap: () => _showEditMomentSheet(context, moment),
      onLongPress: () => _showDeleteMomentDialog(context, moment),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(moment.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              moment.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              countdownText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
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
    TimeOfDay? selectedTime = moment.reminderTime;
    final momentProvider = context.read<MomentProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (ctx, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
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
                      const Text(
                        'ویرایش لحظه ✨',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // انتخاب دسته‌بندی
                      Row(
                        children: [
                          _buildCategoryChip(
                              '🎉', 'قرار', 'appointment', selectedCategory,
                              () {
                            setSheetState(() {
                              selectedCategory = 'appointment';
                              selectedEmoji = '🎉';
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildCategoryChip(
                              '💎', 'مناسبت', 'milestone', selectedCategory,
                              () {
                            setSheetState(() {
                              selectedCategory = 'milestone';
                              selectedEmoji = '💎';
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildCategoryChip(
                              '💋', 'اولین', 'first', selectedCategory, () {
                            setSheetState(() {
                              selectedCategory = 'first';
                              selectedEmoji = '💋';
                            });
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'پیشنهادها:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PresetMoments.getPresetsForCategory(
                          selectedCategory == 'first'
                              ? 'first'
                              : selectedCategory == 'milestone'
                                  ? 'milestone'
                                  : 'appointment',
                        ).map((preset) {
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                titleController.text = preset['title']!;
                                selectedEmoji = preset['emoji']!;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(preset['emoji']!,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(preset['title']!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1A1A2E))),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // انتخاب ایموجی
                      Wrap(
                        spacing: 8,
                        children: [
                          '🎉',
                          '💎',
                          '💋',
                          '❤️',
                          '🌟',
                          '🎂',
                          '✈️',
                          '🍿',
                          '💍',
                          '🏠'
                        ].map((emoji) {
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedEmoji = emoji),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedEmoji == emoji
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.transparent,
                                border: Border.all(
                                    color: selectedEmoji == emoji
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: selectedEmoji == emoji ? 2 : 1),
                              ),
                              child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // فیلد عنوان
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A2E)),
                        decoration: InputDecoration(
                          hintText: 'عنوان لحظه...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // انتخاب تاریخ
                      InkWell(
                        onTap: () async {
                          final picked = await showPersianDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: Jalali(1400, 1, 1),
                            lastDate: Jalali(1410, 12, 29),
                            locale: const Locale('fa', 'IR'),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Color(0xFF8E8E98)),
                              const SizedBox(width: 10),
                              Text(
                                '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF1A1A2E)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // تکرار هر سال
                      Row(
                        children: [
                          const Text('تکرار هر سال:',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF1A1A2E))),
                          const Spacer(),
                          Switch(
                            value: isRecurring,
                            onChanged: (v) =>
                                setSheetState(() => isRecurring = v),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 14),
                      // 🔥 انتخاب زمان
                      InkWell(
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
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            const Icon(Icons.access_time,
                                size: 18, color: Color(0xFF8E8E98)),
                            const SizedBox(width: 10),
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'انتخاب زمان (اختیاری)',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF1A1A2E)),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                reminderTime: selectedTime,
                              );

                              // 🔥 نوتیفیکیشن بعد از ویرایش
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
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                      // دکمه حذف
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // 👈 این خط رو پاک کن: Navigator.pop(context);
                            _showDeleteMomentDialog(
                                context, moment); // مستقیماً دیالوگ رو باز کن
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('حذف این لحظه'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
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

  static void _showDeleteMomentDialog(BuildContext context, Moment moment) {
    if (moment.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.delete_outline, color: Color(0xFFE8456B), size: 24),
          SizedBox(width: 8),
          Text('حذف لحظه',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
        ]),
        content: Text('«${moment.title}» برای همیشه حذف میشه. مطمئنی؟',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E98))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بیخیال',
                  style: TextStyle(color: Color(0xFF8E8E98), fontSize: 13))),
          ElevatedButton(
            onPressed: () async {
              await context.read<MomentProvider>().deleteMoment(moment.id!);
              Navigator.pop(ctx); // اول دیالوگ رو ببند
              Navigator.pop(context); // بعد برگه ویرایش رو ببند
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
