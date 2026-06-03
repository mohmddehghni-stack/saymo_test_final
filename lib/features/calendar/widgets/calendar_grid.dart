import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'day_cell.dart';

class CalendarGrid extends StatefulWidget {
  final int startDay;
  final int daysInMonth;
  final int? selectedDay;
  final int? today;
  final List<int> periodDaysList;
  final Set<int> noteDays;
  final Set<int> momentDays;
  final String? currentUserId;
  final String? partnerId;
  final Map<int, Map<String, dynamic>> savedNotes;
  final Function(int) onDaySelected;
  final List<int> fertileDaysList;
  final int? ovulationDay;
  final List<int> predictedPeriodDaysList;

  const CalendarGrid({
    super.key,
    required this.startDay,
    required this.daysInMonth,
    required this.selectedDay,
    required this.today,
    required this.periodDaysList,
    required this.noteDays,
    this.momentDays = const {},
    this.currentUserId,
    this.partnerId,
    this.savedNotes = const {},
    required this.onDaySelected,
    this.fertileDaysList = const [],
    this.ovulationDay,
    this.predictedPeriodDaysList = const [],
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  @override
  Widget build(BuildContext context) {
    final safeStartDay = (widget.startDay % 7).clamp(0, 6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        final cells = <Widget>[];

        // سلول‌های خالی قبل از روز اول
        for (int i = 0; i < safeStartDay; i++) {
          cells.add(SizedBox(width: cellWidth, height: 40));
        }

        // سلول‌های روزهای ماه
        for (int d = 1; d <= widget.daysInMonth; d++) {
          final dayNotes = widget.savedNotes[d];
          final isMyNote = dayNotes != null &&
              widget.currentUserId != null &&
              dayNotes.containsKey(widget.currentUserId);
          final isPartnerNote = dayNotes != null &&
              widget.partnerId != null &&
              dayNotes.containsKey(widget.partnerId);

          // ─── وضعیت پریود ───
          final hasPeriod = widget.periodDaysList.contains(d);
          final periodIsFirst =
              hasPeriod && !widget.periodDaysList.contains(d - 1);
          final periodIsLast =
              hasPeriod && !widget.periodDaysList.contains(d + 1);

          // ─── وضعیت باروری ───
          final hasFertile = widget.fertileDaysList.contains(d);
          final fertileIsFirst =
              hasFertile && !widget.fertileDaysList.contains(d - 1);
          final fertileIsLast =
              hasFertile && !widget.fertileDaysList.contains(d + 1);
          // ─── وضعیت پیش‌بینی ───
          final hasPredicted = widget.predictedPeriodDaysList.contains(d);
          final predictedIsFirst =
              hasPredicted && !widget.predictedPeriodDaysList.contains(d - 1);
          final predictedIsLast =
              hasPredicted && !widget.predictedPeriodDaysList.contains(d + 1);

          cells.add(
            SizedBox(
              width: cellWidth,
              height: 40,
              child: GestureDetector(
                onTap: () => widget.onDaySelected(d),
                child: DayCell(
                  day: d,
                  isActive:
                      widget.selectedDay != null && d == widget.selectedDay,
                  isToday: widget.today != null && d == widget.today,
                  isPast: widget.today != null && d < widget.today!,
                  hasPeriod: hasPeriod,
                  periodIsFirst: periodIsFirst,
                  periodIsLast: periodIsLast,
                  hasNote: isMyNote || isPartnerNote,
                  hasMoment: widget.momentDays.contains(d),
                  isMyNote: isMyNote,
                  isPartnerNote: isPartnerNote,
                  hasFertile: hasFertile,
                  isOvulationDay: widget.ovulationDay == d,
                  fertileIsFirst: fertileIsFirst,
                  fertileIsLast: fertileIsLast,
                  hasPredictedPeriod: hasPredicted,
                  predictedIsFirst: predictedIsFirst,
                  predictedIsLast: predictedIsLast,
                ),
              ),
            ),
          );
        }

        if (cells.isEmpty) return const SizedBox.shrink();

        // چینش در ردیف‌های ۷ تایی
        final rows = <Widget>[];
        for (int i = 0; i < cells.length; i += 7) {
          final end = min(i + 7, cells.length);
          final rowCells = cells.sublist(i, end);

          while (rowCells.length < 7) {
            rowCells.add(SizedBox(width: cellWidth, height: 40));
          }

          rows.add(Row(mainAxisSize: MainAxisSize.min, children: rowCells));
        }

        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      },
    );
  }
}
