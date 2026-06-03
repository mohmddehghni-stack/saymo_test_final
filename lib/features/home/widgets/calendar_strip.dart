import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'calendar_capsule.dart';
import 'package:flutter_application_1/core/services/event_bus.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({super.key});

  List<Map<String, dynamic>> _getCurrentWeek(
      CalendarProvider cp, MomentProvider mp) {
    final now = Jalali.now();
    const persianDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    final start = now.addDays(-3);

    return List.generate(7, (i) {
      final day = start.addDays(i);
      final dateKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      final hasNote = cp.savedNotesWithFullKey.containsKey(dateKey);
      final hasEvent = mp.moments.any((m) =>
          m.date.year == day.year &&
          m.date.month == day.month &&
          m.date.day == day.day);

      return {
        'title': persianDays[day.weekDay - 1],
        'number': day.day,
        'month': day.month,
        'year': day.year,
        'isToday': day.day == now.day &&
            day.month == now.month &&
            day.year == now.year,
        'hasNote': hasNote || hasEvent,
        'dateKey': dateKey,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalendarProvider>();
    final mp = context.watch<MomentProvider>();
    final days = _getCurrentWeek(cp, mp);
    context.watch<EventBus>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (i) {
          final d = days[i];
          final isSelected = d['isToday'] == true;

          return GestureDetector(
            onTap: () {
              cp.changeMonth(d['year'] as int, d['month'] as int);
              cp.selectDay(d['number'] as int);
            },
            child: CalendarCapsule(
              title: d['title'] as String,
              number: d['number'] as int,
              isSelected: isSelected,
              hasNote: d['hasNote'] as bool,
            ),
          );
        }),
      ),
    );
  }
}
