import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/features/calendar/data/preset_moments.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class MomentSwipeCards extends StatefulWidget {
  const MomentSwipeCards({super.key});

  @override
  State<MomentSwipeCards> createState() => _MomentSwipeCardsState();
}

class _MomentSwipeCardsState extends State<MomentSwipeCards>
    with TickerProviderStateMixin {
  static const double cardHeight = 110.0;
  static const double visibleOffset = 10.0;

  double _dragOffset = 0.0;
  bool _isDragging = false;

  late AnimationController _sinkController;
  late Animation<double> _sinkAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Moment? _lastMoment;

  int _currentGlobalIndex = 0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progressAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _sinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sinkAnimation = CurvedAnimation(
      parent: _sinkController,
      curve: Curves.easeIn,
    );

    _sinkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentGlobalIndex = (_currentGlobalIndex + 1) %
              context.read<MomentProvider>().upcoming.length;
          _dragOffset = 0;
          _sinkController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _sinkController.dispose();
    super.dispose();
  }

  void _updateProgress(Moment moment) {
    if (_lastMoment == moment) return;
    _lastMoment = moment;

    // 👈 محاسبه درصد پیشرفت به صورت شمسی
    final now = Jalali.now();
    final target = moment.date;

    int totalDays;
    if (moment.isRecurring) {
      totalDays = 365;
    } else {
      totalDays = _daysBetween(now, target).abs();
      if (totalDays == 0) totalDays = 1;
    }

    int passedDays = 0;
    if (moment.isRecurring) {
      final lastYear = Jalali(now.year - 1, target.month, target.day);
      passedDays = _daysBetween(lastYear, now).abs();
      if (passedDays > 365) passedDays = 365;
    }

    _progressController.reset();
    _progressController.duration = const Duration(seconds: 1);
    _progressController.value = (passedDays / totalDays).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MomentProvider>();
    final cp = context.read<CalendarProvider>();
    final allMoments = mp.upcoming
        .where((m) => !m.isPrivate || m.userId == cp.userId)
        .toList();
    if (allMoments.isEmpty) return const SizedBox.shrink();
    final totalMoments = allMoments.length;
    final activeDotIndex = _currentGlobalIndex % totalMoments;

    final visibleCards = <Moment>[];
    for (int i = 0; i < 3; i++) {
      final idx = (_currentGlobalIndex + i) % totalMoments;
      visibleCards.add(allMoments[idx]);
    }

    final currentMoment = visibleCards.first;
    _updateProgress(currentMoment);

    final stackHeight = cardHeight + (visibleCards.length - 1) * visibleOffset;
    final isSinking =
        _sinkController.isAnimating || _sinkController.value > 0.0;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(visibleCards.length, (i) {
          final displayIndex = visibleCards.length - 1 - i;
          final moment = visibleCards[displayIndex];
          final isTop = displayIndex == 0;

          double baseScale = 1.0 - (displayIndex * 0.05);
          double baseOpacity = 1.0 - (displayIndex * 0.08);
          double dragProgress = (_dragOffset.abs() / 120).clamp(0.0, 1.0);

          double scale, opacity;
          if (isTop) {
            if (isSinking) {
              scale = 1.0 - (_sinkAnimation.value * 0.15);
              opacity = 1.0 - _sinkAnimation.value;
            } else {
              scale = 1.0;
              opacity = 1.0 - (_dragOffset.abs() / 200).clamp(0.0, 0.8);
            }
          } else {
            scale = baseScale + (1.0 - baseScale) * dragProgress * 0.3;
            opacity = baseOpacity + (1.0 - baseOpacity) * dragProgress * 0.3;
          }

          double baseMargin = 16.0 + (displayIndex * 4.0);
          double marginLR =
              isTop ? baseMargin : baseMargin - (dragProgress * 3);

          double topPosition;
          if (isTop && isSinking) {
            topPosition = displayIndex * visibleOffset +
                _sinkAnimation.value * (cardHeight - visibleOffset);
          } else {
            topPosition =
                displayIndex * visibleOffset - (isTop ? 0 : dragProgress * 2);
          }

          double leftOffset = marginLR;
          double rightOffset = marginLR;
          if (isTop) {
            if (isSinking) {
              leftOffset += _dragOffset * (1 - _sinkAnimation.value);
              rightOffset -= _dragOffset * (1 - _sinkAnimation.value);
            } else {
              leftOffset += _dragOffset;
              rightOffset -= _dragOffset;
            }
          }

          return Positioned(
            top: topPosition,
            left: leftOffset,
            right: rightOffset,
            child: IgnorePointer(
              ignoring: !isTop || isSinking,
              child: GestureDetector(
                onHorizontalDragUpdate: isTop && !isSinking
                    ? (details) {
                        setState(() {
                          _isDragging = true;
                          _dragOffset += details.primaryDelta ?? 0;
                        });
                      }
                    : null,
                onHorizontalDragEnd: isTop && !isSinking
                    ? (details) {
                        _isDragging = false;
                        if (_dragOffset.abs() > 80) {
                          _sinkController.forward(from: 0);
                        } else {
                          setState(() => _dragOffset = 0);
                        }
                      }
                    : null,
                onTap: isTop && !isSinking
                    ? () => _showEditMomentSheet(moment)
                    : null,
                onLongPress: isTop && !isSinking
                    ? () => _showDeleteMomentDialog(moment)
                    : null,
                child: Stack(
                  children: [
                    AnimatedOpacity(
                      duration: isSinking
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          height: cardHeight,
                          child: _buildCardContent(moment, isTop, totalMoments),
                        ),
                      ),
                    ),
                    if (isTop && totalMoments > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: List.generate(
                              totalMoments,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: i == activeDotIndex ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: i == activeDotIndex
                                      ? const Color(0xFFE8456B)
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCardContent(Moment moment, bool isTop, int totalMoments) {
    // 👈 استفاده از countdownText به جای محاسبه میلادی
    final momentProvider = context.read<MomentProvider>();
    final countdownText = momentProvider.countdownText(moment);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isTop ? Colors.grey.shade200 : Colors.grey.shade300,
            width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isTop ? 0.08 : 0.04),
            blurRadius: isTop ? 16 : 8,
            offset: Offset(0, isTop ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: _getCategoryColors(moment.category)),
                ),
                child: Center(
                    child: Text(moment.emoji,
                        style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(moment.title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isTop
                                ? const Color(0xFF1A1A2E)
                                : const Color(0xFF8E8E98))),
                    const SizedBox(height: 2),
                    // 👈 نمایش متن شمارش معکوس درست
                    Text(
                      countdownText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE8456B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isTop) ...[
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColors(moment.category).last),
                    minHeight: 4,
                  ),
                );
              },
            ),
            if (totalMoments > 1) const SizedBox(height: 5),
          ],
        ],
      ),
    );
  }

  void _showEditMomentSheet(Moment moment) {
    final titleController = TextEditingController(text: moment.title);
    MomentCategory selectedCategory = moment.category;
    String selectedEmoji = moment.emoji;
    Jalali selectedDate = moment.date;
    bool isRecurring = moment.isRecurring;

    final momentProvider = context.read<MomentProvider>();
    final cp = context.read<CalendarProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28), topRight: Radius.circular(28)),
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
                  const Text('ویرایش لحظه ✨',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildCategoryChip('🎉', 'قرار',
                          MomentCategory.appointment, selectedCategory, () {
                        setSheetState(() {
                          selectedCategory = MomentCategory.appointment;
                          selectedEmoji = '🎉';
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildCategoryChip('💎', 'مناسبت',
                          MomentCategory.milestone, selectedCategory, () {
                        setSheetState(() {
                          selectedCategory = MomentCategory.milestone;
                          selectedEmoji = '💎';
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                          '💋', 'اولین', MomentCategory.first, selectedCategory,
                          () {
                        setSheetState(() {
                          selectedCategory = MomentCategory.first;
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
                        color: Color(0xFF8E8E98)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PresetMoments.getPresetsForCategory(
                            selectedCategory == MomentCategory.first
                                ? 'first'
                                : selectedCategory == MomentCategory.milestone
                                    ? 'milestone'
                                    : 'appointment')
                        .map((preset) {
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
                                      fontSize: 12, color: Color(0xFF1A1A2E))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
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
                        onTap: () => setSheetState(() => selectedEmoji = emoji),
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
                                  style: const TextStyle(fontSize: 18))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'عنوان لحظه...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                          activeColor: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                              isRecurring: isRecurring);
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: const Text('ذخیره 💕',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showDeleteMomentDialog(moment);
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
      ),
    );
  }

  void _showDeleteMomentDialog(Moment moment) {
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
            onPressed: () {
              context.read<MomentProvider>().deleteMoment(moment.id!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8456B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('آره، حذف کن',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String emoji, String label, MomentCategory category,
      MomentCategory selected, VoidCallback onTap) {
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

  List<Color> _getCategoryColors(MomentCategory category) {
    switch (category) {
      case MomentCategory.milestone:
        return [Colors.amber.shade300, Colors.amber.shade500];
      case MomentCategory.first:
        return [Colors.deepOrange.shade300, Colors.deepOrange.shade500];
      default:
        return [AppColors.primary, const Color(0xFFE8456B)];
    }
  }

  // 👈👈👈 توابع کمکی جدید 👈👈👈
  int _daysBetween(Jalali from, Jalali to) {
    int days = 0;
    if (from.year == to.year && from.month == to.month) {
      return to.day - from.day;
    }
    if (from.year == to.year) {
      days += _getMonthDays(from.month, from.year) - from.day;
      for (int m = from.month + 1; m < to.month; m++) {
        days += _getMonthDays(m, from.year);
      }
      days += to.day;
      return days;
    }
    days += _getMonthDays(from.month, from.year) - from.day;
    for (int m = from.month + 1; m <= 12; m++) {
      days += _getMonthDays(m, from.year);
    }
    for (int y = from.year + 1; y < to.year; y++) {
      days += _isLeapYear(y) ? 366 : 365;
    }
    for (int m = 1; m < to.month; m++) {
      days += _getMonthDays(m, to.year);
    }
    days += to.day;
    return days;
  }

  int _getMonthDays(int month, int year) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return _isLeapYear(year) ? 30 : 29;
  }

  bool _isLeapYear(int year) {
    final d = Jalali(year, 1, 1);
    final next = d.addDays(365);
    return next.month == 12 && next.day == 30;
  }

  String _getMonthName(int month) {
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
