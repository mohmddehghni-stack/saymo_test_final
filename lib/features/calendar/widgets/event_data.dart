import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:shamsi_date/shamsi_date.dart';

class EventData {
  final String icon;
  final String text;
  final String shortText;
  final Color color;
  final Jalali date;

  const EventData({
    required this.icon,
    required this.text,
    required this.shortText,
    required this.color,
    required this.date,
  });

  factory EventData.fromLegacy({
    required String icon,
    required String text,
    required String shortText,
    required Color color,
    required int day,
    int? month,
    int? year,
  }) {
    final now = Jalali.now();
    return EventData(
      icon: icon,
      text: text,
      shortText: shortText,
      color: color,
      date: Jalali(
        year ?? now.year,
        month ?? now.month,
        day,
      ),
    );
  }

  int get day => date.day;
  int get month => date.month;
  int get year => date.year;

  String get formattedDate {
    final monthNames = [
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
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  bool isForDate(Jalali targetDate) {
    return date.year == targetDate.year &&
        date.month == targetDate.month &&
        date.day == targetDate.day;
  }

  bool get isToday {
    final now = Jalali.now();
    return isForDate(now);
  }

  bool get isFuture {
    return daysUntil() > 0;
  }

  bool get isPast {
    return daysUntil() < 0;
  }

  // 🔥 اصلاح: محاسبه با تاریخ شمسی مستقیم
  int daysUntil() {
    final now = Jalali.now();

    // محاسبه اختلاف روز با تاریخ شمسی
    final nowInDays = now.year * 365 + now.month * 30 + now.day;
    final eventInDays = date.year * 365 + date.month * 30 + date.day;

    return eventInDays - nowInDays;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventData &&
        other.date == date &&
        other.icon == icon &&
        other.text == text;
  }

  @override
  int get hashCode => Object.hash(date, icon, text);

  @override
  String toString() {
    return 'EventData(icon: $icon, text: $text, date: $formattedDate)';
  }
}
