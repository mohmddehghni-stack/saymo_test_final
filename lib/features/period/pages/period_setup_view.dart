import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/providers/period_provider.dart';
import '../../../../core/theme/app_colors.dart';

class PeriodSetupView extends StatelessWidget {
  final VoidCallback? onCompleted;

  const PeriodSetupView({
    super.key,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final periodProvider = context.watch<PeriodProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF5F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('🌸', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text(
                  'یه چندتا سوال ساده...',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'برای اینکه بتونم کمکت کنم،\nلطفاً اطلاعات زیر رو وارد کن.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    color: Colors.black54,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 32),

                // سوال ۱
                const Text(
                  'آخرین پریودت کی شروع شد؟',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await _showJalaliDatePicker(
                      context: context,
                      initialDate:
                          periodProvider.lastPeriodStart ?? Jalali.now(),
                    );
                    if (picked != null) {
                      periodProvider.setLastPeriodStart(picked);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          periodProvider.lastPeriodStart != null
                              ? '${periodProvider.lastPeriodStart!.day} ${_monthName(periodProvider.lastPeriodStart!.month)} ${periodProvider.lastPeriodStart!.year}'
                              : 'انتخاب تاریخ',
                          style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 16,
                            color: periodProvider.lastPeriodStart != null
                                ? AppColors.primaryDark
                                : Colors.grey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            color: AppColors.primaryDark, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // سوال ۲
                const Text(
                  'معمولاً چند روز طول می‌کشه؟',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _setupButton(
                        () => periodProvider
                            .setPeriodLength(periodProvider.periodLength - 1),
                        Icons.remove,
                        periodProvider.periodLength > 3,
                      ),
                      Text(
                        '${periodProvider.periodLength} روز',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      _setupButton(
                        () => periodProvider
                            .setPeriodLength(periodProvider.periodLength + 1),
                        Icons.add,
                        periodProvider.periodLength < 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // سوال ۳
                const Text(
                  'معمولاً هر چند روز یکبار پریود میشی؟',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 14,
                    color: Color(0xFF5D4037),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(طول چرخه = فاصله بین دو پریود)',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _setupButton(
                        () => periodProvider
                            .setCycleLength(periodProvider.cycleLength - 1),
                        Icons.remove,
                        periodProvider.cycleLength > 21,
                      ),
                      Text(
                        '${periodProvider.cycleLength} روز',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      _setupButton(
                        () => periodProvider
                            .setCycleLength(periodProvider.cycleLength + 1),
                        Icons.add,
                        periodProvider.cycleLength < 35,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // دکمه ذخیره
                // دکمه ذخیره
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
                    onPressed: periodProvider.lastPeriodStart != null
                        ? () {
                            periodProvider.setSetupDone(true);
                            onCompleted?.call();
                          }
                        : null,
                    child: const Text(
                      'ذخیره و شروع 💾',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                if (periodProvider.lastPeriodStart == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'لطفاً تاریخ آخرین پریود رو انتخاب کن',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 12,
                      color: Colors.red.shade400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Jalali?> _showJalaliDatePicker({
    required BuildContext context,
    required Jalali initialDate,
  }) async {
    final now = Jalali.now();
    final firstDate = Jalali(now.year - 2, now.month, now.day);
    final lastDate = now;

    return showDialog<Jalali>(
      context: context,
      builder: (context) => _JalaliDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  Widget _setupButton(VoidCallback onTap, IconData icon, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryDark.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primaryDark : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
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
    return months[month];
  }
}

// پیکر تاریخ شمسی (بدون تغییر)
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
  late int _selectedYear;
  late int _selectedMonth;
  late Jalali _selectedDate;
  late PageController _pageController;

  static const Color primaryPink = Color(0xFFE8456B);
  static const Color softPink = AppColors.periodBackground;

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();
    _selectedDate = widget.initialDate;
    _selectedYear = now.year;
    _selectedMonth = now.month;
    final initialTotalMonth =
        widget.initialDate.year * 12 + widget.initialDate.month - 1;
    final nowTotalMonth = now.year * 12 + now.month - 1;
    final pageOffset = nowTotalMonth - initialTotalMonth;
    _pageController = PageController(initialPage: 12 + pageOffset);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getMonthFromPage(int page) {
    final baseMonth = widget.initialDate.month;
    final baseYear = widget.initialDate.year;
    final totalMonth = baseYear * 12 + baseMonth - 1 + (page - 12);
    return totalMonth;
  }

  Jalali _getMonthDate(int page) {
    final totalMonth = _getMonthFromPage(page);
    final year = totalMonth ~/ 12;
    final month = (totalMonth % 12) + 1;
    return Jalali(year, month, 1);
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
                    _selectedYear = date.year;
                    _selectedMonth = date.month;
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
        _navButton(
            Icons.chevron_right_rounded,
            () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut)),
        Column(children: [
          Text(monthNames[_selectedMonth],
              style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  decoration: TextDecoration.none)),
          Text('$_selectedYear',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.none)),
        ]),
        _navButton(
            Icons.chevron_left_rounded,
            () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut)),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: softPink, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: primaryPink, size: 22),
      ),
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
                        decoration: TextDecoration.none))),
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
            crossAxisSpacing: 4),
        itemCount: 42,
        itemBuilder: (context, index) {
          final dayNumber = index - startOffset + 1;
          if (dayNumber < 1 || dayNumber > daysInMonth)
            return const SizedBox.shrink();
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
                          decoration: TextDecoration.none))),
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
              padding: const EdgeInsets.symmetric(vertical: 14)),
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 15,
                  decoration: TextDecoration.none)),
        )),
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
                elevation: 0),
            onPressed: () => Navigator.pop(context, _selectedDate),
            child: Text(
                '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} $_selectedYear',
                style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none)),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month];
  }
}
