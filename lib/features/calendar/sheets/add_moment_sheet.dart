import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
// 🔥 این خط حذف شد: import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/features/calendar/data/preset_moments.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMomentSheet {
  static const Color primaryPink = AppColors.primary;
  static const Color softBg = AppColors.backgroundLight;
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8E8E98);

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
    MomentCategory selectedCategory = MomentCategory.appointment;
    String selectedEmoji = '🎉';
    final Set<String> _selectedTitles = {};
    Jalali selectedDate = Jalali.now();
    bool isRecurring = false;
    bool isPrivate = false;
    final cp = context.read<CalendarProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final mp = context.read<MomentProvider>();
          return Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.only(
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
                  const Text('ثبت لحظه جدید ✨',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark)),
                  const SizedBox(height: 16),

                  // نوع لحظه
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Text('نوع لحظه:',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textDark))),
                  const SizedBox(height: 8),
                  Row(children: [
                    _buildCategoryOption(
                        '🎉',
                        'قرار',
                        MomentCategory.appointment,
                        selectedCategory,
                        () => setSheetState(() {
                              selectedCategory = MomentCategory.appointment;
                              selectedEmoji = '🎉';
                              _selectedTitles.clear();
                              _searchController.clear();
                            })),
                    const SizedBox(width: 8),
                    _buildCategoryOption(
                        '💎',
                        'مناسبت',
                        MomentCategory.milestone,
                        selectedCategory,
                        () => setSheetState(() {
                              selectedCategory = MomentCategory.milestone;
                              selectedEmoji = '💎';
                              _selectedTitles.clear();
                              _searchController.clear();
                            })),
                    const SizedBox(width: 8),
                    _buildCategoryOption(
                        '💋',
                        'اولین',
                        MomentCategory.first,
                        selectedCategory,
                        () => setSheetState(() {
                              selectedCategory = MomentCategory.first;
                              selectedEmoji = '💋';
                              _selectedTitles.clear();
                              _searchController.clear();
                            })),
                  ]),
                  const SizedBox(height: 16),

                  // ─── مناسبت‌ها ───
                  if (selectedCategory == MomentCategory.milestone) ...[
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Text('انتخاب مناسبت:',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textDark))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, color: textDark),
                      decoration: InputDecoration(
                        hintText: 'جستجو: تولد، سالگرد، ولنتاین...',
                        hintStyle: TextStyle(
                            color: textGrey.withOpacity(0.5), fontSize: 12),
                        filled: true,
                        fillColor: softBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 18, color: textGrey),
                      ),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 160,
                      child: SingleChildScrollView(
                        child: Builder(builder: (context) {
                          final allPresets = PresetMoments.milestones;
                          final query = _searchController.text.trim();
                          final filtered = query.isEmpty
                              ? allPresets
                              : allPresets
                                  .where((p) => p['title']!.contains(query))
                                  .toList();
                          if (filtered.isEmpty)
                            return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('موردی پیدا نشد',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: textGrey.withOpacity(0.6))));
                          return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filtered.map((preset) {
                                final isSelected =
                                    _selectedTitles.contains(preset['title']);
                                return GestureDetector(
                                  onTap: () => setSheetState(() {
                                    if (isSelected) {
                                      _selectedTitles.remove(preset['title']);
                                    } else {
                                      _selectedTitles.add(preset['title']!);
                                    }
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: isSelected
                                            ? primaryPink.withOpacity(0.1)
                                            : softBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: isSelected
                                                ? primaryPink
                                                : Colors.grey.shade200)),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(preset['emoji']!,
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          const SizedBox(width: 4),
                                          Text(preset['title']!,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSelected
                                                      ? primaryPink
                                                      : textDark)),
                                          if (isSelected) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                size: 16,
                                                color: primaryPink)
                                          ],
                                        ]),
                                  ),
                                );
                              }).toList());
                        }),
                      ),
                    ),
                    if (_selectedTitles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Align(
                          alignment: Alignment.centerRight,
                          child: Text('انتخاب‌ها:',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textDark))),
                      const SizedBox(height: 8),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedTitles.map((title) {
                            final preset = PresetMoments.milestones
                                .firstWhere((p) => p['title'] == title);
                            return Chip(
                                label: Text('${preset['emoji']} $title',
                                    style: const TextStyle(fontSize: 12)),
                                deleteIcon:
                                    const Icon(Icons.close_rounded, size: 14),
                                onDeleted: () => setSheetState(
                                    () => _selectedTitles.remove(title)),
                                backgroundColor: primaryPink.withOpacity(0.08),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)));
                          }).toList()),
                    ],
                    const SizedBox(height: 16),
                  ] else ...[
                    // ─── قرار / اولین ───
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Text('ایموجی:',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textDark))),
                    const SizedBox(height: 8),
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
                                      ? primaryPink.withOpacity(0.15)
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: selectedEmoji == emoji
                                          ? primaryPink
                                          : Colors.grey.shade300,
                                      width: selectedEmoji == emoji ? 2 : 1)),
                              child: Center(
                                  child: Text(emoji,
                                      style: TextStyle(fontSize: 18))),
                            ),
                          );
                        }).toList()),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14, color: textDark),
                      decoration: InputDecoration(
                          hintText: 'عنوان لحظه...',
                          hintStyle:
                              TextStyle(color: textGrey.withOpacity(0.5)),
                          filled: true,
                          fillColor: softBg,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(14)),
                    ),
                    const SizedBox(height: 14),
                    const Align(
                        alignment: Alignment.centerRight,
                        child: Text('پیشنهادها:',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textDark))),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.black,
                              Colors.black,
                              Colors.transparent
                            ],
                            stops: [
                              0.0,
                              0.5,
                              0.8,
                              1.0
                            ]).createShader(rect),
                        blendMode: BlendMode.dstIn,
                        child: SingleChildScrollView(
                          child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: PresetMoments.getPresetsForCategory(
                                      selectedCategory == MomentCategory.first
                                          ? 'first'
                                          : 'appointment')
                                  .map((preset) {
                                return GestureDetector(
                                  onTap: () => setSheetState(() {
                                    titleController.text = preset['title']!;
                                    selectedEmoji = preset['emoji']!;
                                  }),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: softBg,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.grey.shade200)),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(preset['emoji']!,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                            const SizedBox(width: 4),
                                            Text(preset['title']!,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: textDark))
                                          ])),
                                );
                              }).toList()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🔥🔥🔥 تاریخ - فقط این بخش تغییر کرده 🔥🔥🔥
                  InkWell(
                    onTap: () async {
                      final picked = await _showJalaliDatePicker(
                        context: context,
                        initialDate: selectedDate,
                      );
                      if (picked != null)
                        setSheetState(() => selectedDate = picked);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: softBg,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: textGrey),
                          const SizedBox(width: 10),
                          Text(
                              '${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                              style: const TextStyle(
                                  fontSize: 14, color: textDark))
                        ])),
                  ),
                  const SizedBox(height: 14),

                  // تکرار
                  Row(children: [
                    const Text('تکرار هر سال:',
                        style: TextStyle(fontSize: 13, color: textDark)),
                    const Spacer(),
                    Switch(
                        value: isRecurring,
                        onChanged: (v) => setSheetState(() => isRecurring = v),
                        activeColor: primaryPink)
                  ]),
                  const SizedBox(height: 14),

                  // دفترچه شخصی
                  Row(children: [
                    const Text('فقط برای خودم',
                        style: TextStyle(fontSize: 13, color: textDark)),
                    const Spacer(),
                    Switch(
                        value: isPrivate,
                        onChanged: (v) => setSheetState(() => isPrivate = v),
                        activeColor: primaryPink)
                  ]),
                  const SizedBox(height: 20),

                  // دکمه ثبت
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final mp = context.read<MomentProvider>();

                        // 🔥 اگه init نشده، از AppProvider مقدار بگیر
                        if (!mp.isInitialized) {
                          final appProvider = context.read<AppProvider>();
                          print(
                              '🔘 AppProvider - userId: ${appProvider.userId}, partnerId: ${appProvider.partnerId}');

                          if (appProvider.userId != null &&
                              appProvider.partnerId != null &&
                              appProvider.partnerId!.isNotEmpty) {
                            mp.init(
                                appProvider.userId!, appProvider.partnerId!);
                            print('✅ از AppProvider init شد');
                          } else {
                            print('❌ AppProvider هم partnerId نداره!');
                            // 🔥 یه راه دیگه: از SharedPreferences مستقیم بخون
                            final prefs = await SharedPreferences.getInstance();
                            final partnerId = prefs.getString('partnerId');
                            print('🔘 SharedPreferences partnerId: $partnerId');

                            if (partnerId != null && partnerId.isNotEmpty) {
                              mp.init(appProvider.userId ?? '46', partnerId);
                              print('✅ از SharedPreferences init شد');
                            } else {
                              print('❌ هیچ جا partnerId نیست!');
                              return;
                            }
                          }
                        }

                        // ثبت لحظه
                        if (titleController.text.trim().isNotEmpty) {
                          mp.addMoment(
                            title: titleController.text.trim(),
                            date: selectedDate,
                            category: selectedCategory,
                            emoji: selectedEmoji,
                            isRecurring: isRecurring,
                            isPrivate: isPrivate,
                          );
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
                          selectedCategory == MomentCategory.milestone
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
      ),
    );
  }

  // =============================================
  // 🔥 متد جدید: پیکر تاریخ شمسی
  // =============================================
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

  static Widget _buildCategoryOption(String emoji, String label,
      MomentCategory category, MomentCategory selected, VoidCallback onTap) {
    final isSelected = selected == category;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? primaryPink.withOpacity(0.08) : softBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSelected
                      ? primaryPink.withOpacity(0.3)
                      : Colors.transparent)),
          child: Column(children: [
            Text(emoji, style: TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? primaryPink : textGrey))
          ]),
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
  static const Color softPink = AppColors.periodBackground;

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
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
                itemBuilder: (context, page) => _buildCalendarGrid(page),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              color: softPink,
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
              style: const TextStyle(
                fontFamily: 'Vazir',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              '$_viewYear',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 12,
                  color: Colors.grey.shade500),
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
              color: softPink,
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

  Widget _buildCalendarGrid(int page) {
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
                        ? softPink
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
                                  : const Color(0xFF333333),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
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
