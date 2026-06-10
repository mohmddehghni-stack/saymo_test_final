import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';
import 'calendar_grid.dart';
import 'event_chips.dart';
import 'moment_swipe_cards.dart';
import 'notes_section.dart';
import 'event_data.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';

class CalendarContent extends StatelessWidget {
  const CalendarContent({super.key});

  static const Color primaryPink = AppColors.primary;
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8E8E98);

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalendarProvider>();
    context.watch<MomentProvider>();
    context.watch<PeriodProvider>();

    final mp = context.read<MomentProvider>();

    for (final m in mp.moments) {}

    final allEvents = _getAllEvents(context, cp);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildCalendar(context, cp),
          const SizedBox(height: 12),
          if (allEvents.isNotEmpty) EventChips(allEvents: allEvents, cp: cp),
          const SizedBox(height: 16),
          const MomentSwipeCards(),
          const SizedBox(height: 20),
          NotesSection(cp: cp),
        ],
      ),
    );
  }

  // ─── متدهای کمکی با تاریخ کامل ───

  List<Jalali> _getPeriodDates(BuildContext context, CalendarProvider cp) {
    try {
      final pp = context.read<PeriodProvider>();
      if (pp.lastPeriodStart == null) return [];

      final start = pp.lastPeriodStart!;
      final periodDates = <Jalali>[];

      for (int i = 0; i < pp.periodLength; i++) {
        final day = start.addDays(i);
        if (day.month == cp.selectedMonth && day.year == cp.selectedYear) {
          periodDates.add(day);
        }
      }

      return periodDates;
    } catch (e) {
      return [];
    }
  }

  List<Jalali> _getPredictedPeriodDates(
      BuildContext context, CalendarProvider cp) {
    try {
      final pp = context.read<PeriodProvider>();
      // 🔥 مستقیم از PeriodProvider استفاده کن، دوباره حساب نکن!
      return pp.getPredictedPeriodDatesForMonth(
          cp.selectedMonth, cp.selectedYear);
    } catch (e) {
      return [];
    }
  }

  List<Jalali> _getFertileDates(BuildContext context, CalendarProvider cp) {
    try {
      final pp = context.read<PeriodProvider>();
      // 🔥 مستقیم از PeriodProvider استفاده کن، دوباره حساب نکن!
      return pp.getFertileDatesForMonth(cp.selectedMonth, cp.selectedYear);
    } catch (e) {
      return [];
    }
  }

  Jalali? _getOvulationDate(BuildContext context, CalendarProvider cp) {
    try {
      final pp = context.read<PeriodProvider>();
      // 🔥 مستقیم از PeriodProvider استفاده کن، دوباره حساب نکن!
      return pp.getOvulationDateForMonth(cp.selectedMonth, cp.selectedYear);
    } catch (e) {
      return null;
    }
  }

  List<int> _toDayList(List<Jalali> dates) {
    return dates.map((d) => d.day).toList();
  }

  // ─── تقویم ───

  Widget _buildCalendar(BuildContext context, CalendarProvider cp) {
    final pp = context.read<PeriodProvider>();
    final appProvider = context.read<AppProvider>();

    final isFemale = appProvider.gender == 'female';

    // 🔥 بر اساس جنسیت تصمیم بگیر از کدوم داده استفاده کنه
    List<Jalali> periodDates;
    List<Jalali> predictedPeriodDates;
    List<Jalali> fertileDates;
    Jalali? ovulationDate;

    if (isFemale) {
      periodDates =
          pp.getPeriodDatesForMonth(cp.selectedMonth, cp.selectedYear);
      predictedPeriodDates =
          pp.getPredictedPeriodDatesForMonth(cp.selectedMonth, cp.selectedYear);
      fertileDates =
          pp.getFertileDatesForMonth(cp.selectedMonth, cp.selectedYear);
      ovulationDate =
          pp.getOvulationDateForMonth(cp.selectedMonth, cp.selectedYear);
    } else {
      periodDates =
          pp.getPartnerPeriodDatesForMonth(cp.selectedMonth, cp.selectedYear);
      predictedPeriodDates = pp.getPartnerPredictedPeriodDatesForMonth(
          cp.selectedMonth, cp.selectedYear);
      fertileDates = pp.getPartnerFertileDatesForMonth(
          cp.selectedMonth, cp.selectedYear); // ✅
      ovulationDate =
          pp.getPartnerOvulationDateForMonth(cp.selectedMonth, cp.selectedYear);
    }

    final noteDaysSet = <int>{};
    cp.savedNotes.forEach((key, value) {
      if (key is int) {
        noteDaysSet.add(key);
      }
    });

    final momentDaysSet = context
        .read<MomentProvider>()
        .moments
        .where((m) =>
            m.date.month == cp.selectedMonth && m.date.year == cp.selectedYear)
        .map((m) => m.date.day)
        .toSet();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _navButton(Icons.chevron_left_rounded, () {
                    if (cp.selectedMonth == 1) {
                      cp.changeMonth(cp.selectedYear - 1, 12);
                    } else {
                      cp.changeMonth(cp.selectedYear, cp.selectedMonth - 1);
                    }
                  }),
                  Text(
                    cp.monthName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _navButton(Icons.chevron_right_rounded, () {
                    if (cp.selectedMonth == 12) {
                      cp.changeMonth(cp.selectedYear + 1, 1);
                    } else {
                      cp.changeMonth(cp.selectedYear, cp.selectedMonth + 1);
                    }
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'].map((d) {
                  final isFriday = d == 'ج';
                  return SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isFriday
                              ? primaryPink.withOpacity(0.7)
                              : textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              child: CalendarGrid(
                startDay: cp.startDay,
                daysInMonth: cp.daysInMonth,
                selectedDay: cp.selectedDay,
                today: cp.todayDay,
                periodDaysList: _toDayList(periodDates),
                fertileDaysList: _toDayList(fertileDates), // 🔥 برمی‌گرده
                ovulationDay: ovulationDate?.day,
                predictedPeriodDaysList: _toDayList(predictedPeriodDates),
                noteDays: noteDaysSet,
                momentDays: momentDaysSet,
                currentUserId: cp.userId,
                partnerId: cp.partnerId,
                savedNotes: cp.savedNotes,
                onDaySelected: (d) {
                  cp.selectDay(d);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: primaryPink.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: primaryPink),
        ),
      ),
    );
  }

  // ─── رویدادها (برای بنر و چیپ‌ها) ───

  List<EventData> _getAllEvents(BuildContext context, CalendarProvider cp) {
    final events = <EventData>[];
    final appProvider = context.read<AppProvider>();
    final isFemale = appProvider.gender == 'female';

    List<Jalali> periodDates;
    if (isFemale) {
      periodDates = _getPeriodDates(context, cp);
    } else {
      periodDates = _getPartnerPeriodDatesForEvents(context, cp);
    }

    // ۱. یادداشت‌ها
    cp.savedNotesWithFullKey.forEach((key, value) {
      Jalali? date;
      if (key is String) {
        try {
          final parts = key.split('-');
          if (parts.length == 3) {
            date = Jalali(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        } catch (e) {
          return;
        }
      } else {
        return;
      }

      if (date == null) return;
      if (date.month != cp.selectedMonth || date.year != cp.selectedYear)
        return;

      final dayNotes = value;
      if (dayNotes.isEmpty) return;

      if (dayNotes.containsKey(cp.userId)) {
        events.add(EventData(
          icon: '📝',
          text: '${cp.formatDate(date.day)} - یادداشت تو',
          shortText: 'یادداشت ${cp.formatDate(date.day)}',
          color: primaryPink,
          date: date,
        ));
      }

      if (cp.partnerId != null && dayNotes.containsKey(cp.partnerId)) {
        final note = dayNotes[cp.partnerId]!;
        if (note['isPrivate'] != true) {
          events.add(EventData(
            icon: '💕',
            text: '${cp.formatDate(date.day)} - یادداشت پارتنر',
            shortText: 'پارتنر ${cp.formatDate(date.day)}',
            color: const Color(0xFF5B8DEF),
            date: date,
          ));
        }
      }
    });

    // ۲. روزهای پریود
    /*for (final date in periodDates) {
      events.add(EventData(
        icon: '🌸',
        text: '${cp.formatDate(date.day)} - روز پریود',
        shortText: 'پریود ${cp.formatDate(date.day)}',
        color: const Color(0xFFF5576C),
        date: date,
      ));
    }*/

    // ۳. لحظه‌ها
    try {
      final momentProvider = context.read<MomentProvider>();
      for (final moment in momentProvider.moments) {
        if (moment.isPrivate && moment.userId != cp.userId) continue;

        events.add(EventData(
          icon: moment.emoji,
          text: momentProvider.countdownText(moment),
          shortText: moment.title,
          color: moment.category == 'milestone'
              ? Colors.amber.shade600
              : moment.category == 'first'
                  ? Colors.deepOrange.shade300
                  : primaryPink,
          date: moment.date,
        ));
      }
    } catch (e) {
      debugPrint('Error loading moments: $e');
    }

    events.sort((a, b) => a.date.toDateTime().compareTo(b.date.toDateTime()));
    return events;
  }

  List<Jalali> _getPartnerPeriodDatesForEvents(
      BuildContext context, CalendarProvider cp) {
    try {
      final pp = context.read<PeriodProvider>();
      return pp.getPartnerPeriodDatesForMonth(
          cp.selectedMonth, cp.selectedYear);
    } catch (e) {
      return [];
    }
  }
}
