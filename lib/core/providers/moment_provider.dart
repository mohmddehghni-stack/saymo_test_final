import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shamsi_date/shamsi_date.dart';
import '../../shared/services/socket_service.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

class Moment {
  final int? id;
  final String userId;
  final String partnerId;
  final String? coupleId; // 🔥 جدید
  final String title;
  final Jalali date;
  final String category;
  final String emoji;
  final bool isRecurring;
  final bool isPrivate;
  final String? status;
  final Jalali? startDate;
  final bool autoDelete;

  Moment({
    this.id,
    required this.userId,
    required this.partnerId,
    this.coupleId,
    required this.title,
    required this.date,
    this.category = 'appointment',
    this.emoji = '🎉',
    this.isRecurring = false,
    this.isPrivate = false,
    this.status,
    this.startDate,
    this.autoDelete = false,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    final dateStr = json['moment_date']?.toString() ??
        json['moment_date_jalali']?.toString() ??
        '';
    final dateParts = dateStr.split('-');

    return Moment(
      id: json['id'],
      userId: json['user_id']?.toString() ?? '',
      partnerId: json['partner_id']?.toString() ?? '',
      coupleId: json['couple_id']?.toString(),
      title: json['title'] ?? '',
      isPrivate: json['is_private'] == true,
      date: Jalali(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      ),
      category: json['category'] ?? 'appointment',
      emoji: json['emoji'] ?? '🎉',
      isRecurring: json['is_recurring'] == true,
      status: json['status'] ?? 'active',
      startDate:
          json['start_date'] != null ? _parseDate(json['start_date']) : null,
      autoDelete: json['auto_delete'] == true,
    );
  }

  static Jalali _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return Jalali(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  // تبدیل تاریخ شمسی به میلادی برای ارسال به سرور
  DateTime toGregorian() {
    final d = date.toDateTime();
    return d;
  }
}

class MomentProvider extends ChangeNotifier {
  List<Moment> _moments = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isInitialized => ApiService.coupleId != null;
  List<Moment> get moments => List.unmodifiable(_moments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Moment? get nearest {
    final upcoming = this.upcoming;
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  List<Moment> get passedMoments =>
      _moments.where((m) => m.status == 'passed').toList();
  List<Moment> get activeMoments =>
      _moments.where((m) => m.status == 'active').toList();

  List<Moment> get upcoming {
    final now = Jalali.now();
    final list = _moments.where((m) {
      if (m.status == 'passed') return false;
      if (m.date.year > now.year) return true;
      if (m.date.year == now.year && m.date.month > now.month) return true;
      if (m.date.year == now.year &&
          m.date.month == now.month &&
          m.date.day >= now.day) return true;
      return false;
    }).toList();

    list.sort((a, b) {
      if (a.date.year != b.date.year) return a.date.year.compareTo(b.date.year);
      if (a.date.month != b.date.month)
        return a.date.month.compareTo(b.date.month);
      return a.date.day.compareTo(b.date.day);
    });
    return list;
  }

  void init() {
    SocketService.addHandler(_handleSocketMessage);
    loadMoments();
  }

  void _handleSocketMessage(Map<String, dynamic> data) {
    if (data['action'] == 'moment_created' || // 👈 اضافه کن
        data['action'] == 'moment_updated' ||
        data['action'] == 'moment_deleted') {
      loadMoments();
    }
  }

  Future<void> loadMoments() async {
    if (ApiService.coupleId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/calendar/moments');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.token}',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['moments'] as List;
        _moments = list.map((j) => Moment.fromJson(j)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = 'خطا در بارگذاری لحظه‌ها';
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      _errorMessage = 'خطا در اتصال به سرور';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMoment({
    required String title,
    required Jalali date,
    Jalali? startDate,
    String category = 'appointment',
    String emoji = '🎉',
    bool isRecurring = false,
    bool isPrivate = false,
  }) async {
    final coupleId = ApiService.coupleId;
    if (coupleId == null) return;

    final momentDateJalali =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final momentDateGregorian =
        date.toDateTime().toIso8601String().split('T')[0]; // YYYY-MM-DD

    String? startDateJalali, startDateGregorian;
    if (startDate != null) {
      startDateJalali =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      startDateGregorian =
          startDate.toDateTime().toIso8601String().split('T')[0];
    }

    final body = jsonEncode({
      'title': title,
      'momentDateJalali': momentDateJalali,
      'momentDate': momentDateGregorian,
      'startDateJalali': startDateJalali,
      'startDate': startDateGregorian,
      'category': category,
      'emoji': emoji,
      'isRecurring': isRecurring,
      'isPrivate': isPrivate,
      'couple_id': coupleId,
    });

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/calendar/moments');
      final response = await http.post(uri, body: body, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.token}',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadMoments();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error saving moment: $e');
      _errorMessage = 'خطا در ذخیره لحظه';
      notifyListeners();
    }
  }

  Future<void> updateMoment({
    required int id,
    required String title,
    required Jalali date,
    String category = 'appointment',
    String emoji = '🎉',
    bool isRecurring = false,
  }) async {
    final momentDateJalali =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final momentDateGregorian =
        date.toDateTime().toIso8601String().split('T')[0];

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/calendar/moments/$id');
      final response = await http.put(uri,
          body: jsonEncode({
            'title': title,
            'momentDateJalali': momentDateJalali,
            'momentDate': momentDateGregorian,
            'category': category,
            'emoji': emoji,
            'isRecurring': isRecurring,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${ApiService.token}',
          });

      if (response.statusCode == 200) {
        await loadMoments();
      }
    } catch (e) {
      debugPrint('❌ Error updating moment: $e');
    }
  }

  Future<void> deleteMoment(int id) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/calendar/moments/$id');
      final response = await http.delete(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.token}',
      });

      if (response.statusCode == 200) {
        _moments.removeWhere((m) => m.id == id);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'خطا در حذف لحظه';
      notifyListeners();
    }
  }

  Future<List<Moment>> getHistory({String period = 'all'}) async {
    try {
      final uri =
          Uri.parse('${ApiService.baseUrl}/calendar/history?period=$period');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${ApiService.token}',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['history'] as List)
            .map((j) => Moment.fromJson(j))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
    }
    return [];
  }

  String countdownText(Moment moment) {
    final now = Jalali.now();
    final days = _daysBetween(now, moment.date);
    if (days == 0) return 'امروز: ${moment.title} ${moment.emoji}';
    if (days == 1) return 'فردا: ${moment.title} ${moment.emoji}';
    if (days > 0) return '$days روز تا ${moment.title} ${moment.emoji}';
    return '${moment.title} ${moment.emoji}';
  }

  int _daysBetween(Jalali from, Jalali to) {
    int days = 0;
    if (from.year == to.year && from.month == to.month)
      return to.day - from.day;
    if (from.year == to.year) {
      days += _getMonthDays(from.month, from.year) - from.day;
      for (int m = from.month + 1; m < to.month; m++)
        days += _getMonthDays(m, from.year);
      days += to.day;
      return days;
    }
    days += _getMonthDays(from.month, from.year) - from.day;
    for (int m = from.month + 1; m <= 12; m++)
      days += _getMonthDays(m, from.year);
    for (int y = from.year + 1; y < to.year; y++)
      days += _isLeapYear(y) ? 366 : 365;
    for (int m = 1; m < to.month; m++) days += _getMonthDays(m, to.year);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleSocketMessage);
    super.dispose();
  }
}
