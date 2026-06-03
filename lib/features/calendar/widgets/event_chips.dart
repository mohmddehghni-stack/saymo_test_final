import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'event_data.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

class EventChips extends StatelessWidget {
  final List<EventData> allEvents;
  final CalendarProvider cp;

  const EventChips({
    super.key,
    required this.allEvents,
    required this.cp,
  });

  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8E8E98);

  @override
  Widget build(BuildContext context) {
    // 🔥 دیگه فیلتر ماه جاری رو برنداشتیم - همه رویدادها رو نشون بده
    if (allEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    // 🔥 مرتب‌سازی: نزدیک‌ترین رویداد به امروز اول باشه
    final sortedEvents = List<EventData>.from(allEvents);
    sortedEvents.sort((a, b) {
      final now = Jalali.now().toDateTime();
      final aDiff = a.date.toDateTime().difference(now).abs();
      final bDiff = b.date.toDateTime().difference(now).abs();
      return aDiff.compareTo(bDiff);
    });

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sortedEvents.length,
        itemBuilder: (context, index) {
          final event = sortedEvents[index];

          // 🔥 چک می‌کنیم آیا این رویداد برای روز انتخاب شده هست
          final selectedDay = cp.selectedDay;
          final isSelected = selectedDay != null &&
              event.date.day == selectedDay &&
              event.date.month == cp.selectedMonth &&
              event.date.year == cp.selectedYear;

          return GestureDetector(
            onTap: () {
              // 🔥 با کلیک روی چیپ، برو به ماه و روز اون رویداد
              cp.changeMonth(event.date.year, event.date.month);
              // یه تاخیر کوچیک بده که ماه عوض بشه
              Future.delayed(const Duration(milliseconds: 100), () {
                cp.selectDay(event.date.day);
              });
              HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? event.color : cardBg,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isSelected
                      ? event.color.withOpacity(0.4)
                      : event.color.withOpacity(0.15),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: event.color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.icon,
                    style: TextStyle(fontSize: isSelected ? 14 : 11),
                  ),
                  const SizedBox(width: 5),
                  // 🔥 حالا تاریخ رو هم نشون می‌ده که بدونن مال کدوم ماهه
                  Text(
                    event.shortText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : textGrey,
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
}
