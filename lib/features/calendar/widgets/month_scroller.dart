import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:shamsi_date/shamsi_date.dart';

class MonthScroller extends StatefulWidget {
  final int selectedYear;
  final int selectedMonth;
  final Color activeColor;
  final Color inactiveColor;
  final Function(int, int) onMonthChanged;

  const MonthScroller({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.black54,
    required this.onMonthChanged,
  });

  @override
  State<MonthScroller> createState() => _MonthScrollerState();
}

class _MonthScrollerState extends State<MonthScroller> {
  static const List<String> _monthNames = [
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

  late List<({int year, int month, String name})> months;
  FixedExtentScrollController? _controller;

  @override
  void initState() {
    super.initState();
    _buildMonths();
    _scrollToSelected();
  }

  void _buildMonths() {
    final now = Jalali.now();
    months = List.generate(48, (i) {
      final m = now.month - 24 + i;
      final year = now.year + (m - 1) ~/ 12;
      final month = (m - 1) % 12 + 1;
      return (year: year, month: month, name: _monthNames[month - 1]);
    });
  }

  void _scrollToSelected() {
    final index = months.indexWhere(
      (m) => m.year == widget.selectedYear && m.month == widget.selectedMonth,
    );
    if (index >= 0 && _controller?.hasClients == true) {
      _controller?.animateToItem(index,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void didUpdateWidget(MonthScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.selectedMonth != widget.selectedMonth) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            itemExtent: 38,
            diameterRatio: 0.5,
            perspective: 0.003,
            physics: const FixedExtentScrollPhysics(),
            controller: (_controller ??= FixedExtentScrollController(
              initialItem: months
                  .indexWhere((m) =>
                      m.year == widget.selectedYear &&
                      m.month == widget.selectedMonth)
                  .clamp(0, months.length - 1),
            )),
            onSelectedItemChanged: (index) {
              if (index >= 0 && index < months.length) {
                widget.onMonthChanged(months[index].year, months[index].month);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index >= months.length)
                  return const SizedBox();
                final m = months[index];
                final isActive = m.year == widget.selectedYear &&
                    m.month == widget.selectedMonth;
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.name,
                          style: TextStyle(
                              color: isActive
                                  ? widget.activeColor
                                  : widget.inactiveColor,
                              fontSize: isActive ? 17 : 12,
                              fontFamily: 'Vazir',
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      if (m.month == 1 && !isActive)
                        Text('${m.year}',
                            style: TextStyle(
                                color: widget.inactiveColor.withOpacity(0.5),
                                fontSize: 8,
                                fontFamily: 'Vazir')),
                    ],
                  ),
                );
              },
              childCount: months.length,
            ),
          ),
          IgnorePointer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.4), width: 1),
                      bottom: BorderSide(
                          color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
