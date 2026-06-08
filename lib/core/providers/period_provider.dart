import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'dart:async';
import 'package:flutter_application_1/shared/services/hive_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart'; // 🔥 اینو اضافه کن

// =============================================
// مدل داده برای ثبت علائم روزانه
// =============================================
class SymptomLog {
  final int day;
  final int pain;
  final String mood;
  final List<String> symptoms;
  final Jalali date;
  final String? note;

  SymptomLog({
    required this.day,
    required this.pain,
    required this.mood,
    required this.symptoms,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'pain': pain,
        'mood': mood,
        'symptoms': symptoms,
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'note': note,
      };

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    final parts = (json['date'] as String).split('-');
    return SymptomLog(
      day: json['day'] ?? 1,
      pain: json['pain'] ?? 0,
      mood: json['mood'] ?? '😊',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      date:
          Jalali(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
      note: json['note'],
    );
  }
}

// =============================================
// Provider اصلی
// =============================================
class PeriodProvider extends ChangeNotifier {
  late Box _periodBox;
  String? _userId;
  String? _token;
  Timer? _pollTimer;
  String? get currentUserId => _userId;

  // داده‌های اصلی
  Jalali? _lastPeriodStart;
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _isSetupDone = false;
  bool _isPartnerSetupDone = false;
  Jalali? _partnerLastPeriodStart;
  int _partnerCycleLength = 28;
  int _partnerPeriodLength = 5;
  bool _partnerDataLoaded = false;
  bool _hasPartner = false;
  List<SymptomLog> _history = [];

  // ===== GETTERS =====
  Jalali? get lastPeriodStart => _lastPeriodStart;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  bool get isSetupDone => _isSetupDone;
  bool get isPartnerSetupDone => _isPartnerSetupDone;
  Jalali? get partnerLastPeriodStart => _partnerLastPeriodStart;
  int get partnerCycleLength => _partnerCycleLength;
  int get partnerPeriodLength => _partnerPeriodLength;
  bool get partnerDataLoaded => _partnerDataLoaded;
  bool get hasPartner => _hasPartner;
  // 🔥 Getter برای محاسبه روز سیکل پارتنر (برای پسر)
  int get partnerCurrentDay {
    if (_partnerLastPeriodStart == null) return 1;
    final startGregorian = _partnerLastPeriodStart!.toDateTime();
    final nowGregorian = Jalali.now().toDateTime();
    final diff = nowGregorian.difference(startGregorian).inDays + 1;
    if (diff <= 0) return 1;
    if (diff > _partnerCycleLength)
      return ((diff - 1) % _partnerCycleLength) + 1;
    return diff.clamp(1, _partnerCycleLength);
  }

  List<SymptomLog> get history => List.unmodifiable(_history);

  SymptomLog? getSymptomForDate(Jalali date) {
    try {
      return _history.firstWhere(
        (log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  int get currentDay => getDayForDate(Jalali.now());

  int getDayForDate(Jalali date) {
    if (_lastPeriodStart == null) return 1;
    final startGregorian = _lastPeriodStart!.toDateTime();
    final targetGregorian = date.toDateTime();
    final diff = targetGregorian.difference(startGregorian).inDays + 1;
    if (diff <= 0) return 1;
    if (diff > _cycleLength) return ((diff - 1) % _cycleLength) + 1;
    return diff.clamp(1, _cycleLength);
  }

  bool get isOnPeriod {
    if (_lastPeriodStart == null) return false;
    return currentDay <= _periodLength;
  }

  int get ovulationDay => _cycleLength - 14;

  List<int> get fertileWindow {
    final ov = ovulationDay;
    return List.generate(7, (i) => ov - 5 + i)
        .where((d) => d > 0 && d <= _cycleLength)
        .toList();
  }

  // ===== متدهای محاسباتی (بدون تغییر) =====
  List<Jalali> getPeriodDatesForMonth(int month, int year) {
    if (_lastPeriodStart == null) return [];
    final periodDates = <Jalali>[];
    final start = _lastPeriodStart!;
    for (int i = 0; i < _periodLength; i++) {
      final day = start.addDays(i);
      if (day.month == month && day.year == year) {
        periodDates.add(day);
      }
    }
    return periodDates;
  }

  /// فقط پریود بعدی (اولین سیکل آینده)
  List<Jalali> getPredictedPeriodDatesForMonth(int month, int year) {
    if (_lastPeriodStart == null) return [];

    final predictedDates = <Jalali>[];

    // محاسبه تاریخ شروع پریود بعدی
    final nextStart = _lastPeriodStart!.addDays(_cycleLength);

    for (int i = 0; i < _periodLength; i++) {
      final periodDay = nextStart.addDays(i);
      if (periodDay.month == month && periodDay.year == year) {
        predictedDates.add(periodDay);
      }
    }

    return predictedDates;
  }

  List<Jalali> getFertileDatesForMonth(int month, int year) {
    if (_lastPeriodStart == null) return [];
    final fertileDates = <Jalali>[];
    final ovDay = _cycleLength - 14;
    final ovulationDate = _lastPeriodStart!.addDays(ovDay - 1);
    for (int i = -5; i <= 1; i++) {
      final fertileDay = ovulationDate.addDays(i);
      if (fertileDay.month == month && fertileDay.year == year) {
        fertileDates.add(fertileDay);
      }
    }
    return fertileDates;
  }

  Jalali? getOvulationDateForMonth(int month, int year) {
    if (_lastPeriodStart == null) return null;
    final ovDay = _cycleLength - 14;
    final ovulationDate = _lastPeriodStart!.addDays(ovDay - 1);
    if (ovulationDate.month == month && ovulationDate.year == year) {
      return ovulationDate;
    }
    return null;
  }

  bool isPeriodDay(Jalali date) {
    final periodDates = getPeriodDatesForMonth(date.month, date.year);
    return periodDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool isPredictedPeriodDay(Jalali date) {
    final predictedDates =
        getPredictedPeriodDatesForMonth(date.month, date.year);
    return predictedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool isFertileDay(Jalali date) {
    final fertileDates = getFertileDatesForMonth(date.month, date.year);
    return fertileDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool isOvulationDay(Jalali date) {
    final ovulationDate = getOvulationDateForMonth(date.month, date.year);
    return ovulationDate != null &&
        ovulationDate.year == date.year &&
        ovulationDate.month == date.month &&
        ovulationDate.day == date.day;
  }

  List<int> getPredictedPeriodDaysForMonth(int month, int year) {
    return getPredictedPeriodDatesForMonth(month, year)
        .map((date) => date.day)
        .toList();
  }

  List<int> getFertileDaysForMonth(int month, int year) {
    return getFertileDatesForMonth(month, year)
        .map((date) => date.day)
        .toList();
  }

  int? getOvulationDayForMonth(int month, int year) {
    final date = getOvulationDateForMonth(month, year);
    return date?.day;
  }

  String get currentPhase {
    final cd = currentDay;
    if (cd <= _periodLength) return 'قاعدگی';
    if (cd < ovulationDay - 5) return 'فولیکولار';
    if (cd <= ovulationDay + 1) return 'تخمک‌گذاری';
    if (cd <= _cycleLength - 7) return 'لوتئال اولیه';
    return 'PMS';
  }

  int get daysUntilNextPeriod {
    final cd = currentDay;
    return _cycleLength - cd + 1;
  }

  Jalali? get predictedNextPeriod {
    if (_lastPeriodStart == null) return null;
    return _lastPeriodStart!.addDays(_cycleLength);
  }

  // ===== CONSTRUCTOR =====
  PeriodProvider() {
    _periodBox = Hive.box('period_data');
    SocketService.addHandler(_handleSocketMessage); // 🔥
  }
  void _handleSocketMessage(Map<String, dynamic> data) {
    if (data['action'] == 'period_updated') {
      loadPartnerData(); // فقط داده پارتنر رو رفرش کن
    }
  }

  // 🔥 برای دکمه "امروز پریود شدم"
  Future<void> markPeriodToday() async {
    _lastPeriodStart = Jalali.now();
    _isSetupDone = true;

    if (_token == null || _token!.isEmpty) {
      _token = ApiService.token;
    }

    notifyListeners();
    await saveToServer();
  }

  Future<void> loadPartnerData() async {
    // 🔥 اول توکن رو از ApiService بگیر
    _token = ApiService.token;

    if (_token == null || _token!.isEmpty) {
      _partnerDataLoaded = true; // 🔥 اینو true کن که دائماً لودینگ نمونه
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://couple-api.liara.run/api/period/partner-setup'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _hasPartner = data['hasPartner'] ?? false;

        if (_hasPartner && data['isSetupDone'] == true) {
          _isPartnerSetupDone = true;
          _partnerCycleLength = data['cycleLength'] ?? 28;
          _partnerPeriodLength = data['periodLength'] ?? 5;

          if (data['lastPeriodStart'] != null) {
            final parts = data['lastPeriodStart'].split('-');
            _partnerLastPeriodStart = Jalali(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }
        } else {
          _isPartnerSetupDone = false;
        }

        _partnerDataLoaded = true;
      } else {
        _partnerDataLoaded = true; // 🔥 بازم true کن که لودینگ تموم بشه
      }
    } catch (e) {
      _partnerDataLoaded = true; // 🔥 بازم true کن
    }
    notifyListeners();
  }

  // 🔥 مقداردهی اولیه با userId (توکن از ApiService)
  void init(String userId) {
    _userId = userId;
    _token = ApiService.token;
    loadFromServer();
  }

  Future<void> saveSymptomToServer(SymptomLog log) async {
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse('https://couple-api.liara.run/api/period/symptoms'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'date':
              '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}',
          'dateJalali':
              '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}',
          'day': log.day,
          'pain': log.pain,
          'mood': log.mood,
          'symptoms': log.symptoms,
          'note': log.note,
        }),
      );
    } catch (e) {
      debugPrint('❌ Error saving symptom: $e');
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      loadFromServer();
    });
  }

  // 🔥 لود تنظیمات از سرور
  Future<void> loadFromServer() async {
    print(
        '🔵 loadFromServer CALLED. _token: ${_token != null ? "YES" : "NO"}, _userId: $_userId');
    final token = ApiService.token;
    final userId = _userId ?? ApiService.currentUserId; // از هر دو منبع
    if (token == null || userId == null) {
      debugPrint('❌ loadFromServer skipped: token=$token, userId=$userId');
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('https://couple-api.liara.run/api/period/setup/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('🔵 loadFromServer RESPONSE: ${response.statusCode}');
      print('🔵 BODY: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _isSetupDone = data['isSetupDone'] ?? false;
        if (_isSetupDone) {
          _cycleLength = data['cycleLength'] ?? 28;
          _periodLength = data['periodLength'] ?? 5;
          if (data['lastPeriodStart'] != null) {
            final parts = data['lastPeriodStart'].split('-');
            _lastPeriodStart = Jalali(
                int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ loadFromServer error: $e');
    }
  }

  // 🔥 ذخیره تنظیمات روی سرور
  Future<void> saveToServer() async {
    print(
        '🔴 saveToServer CALLED. _userId: $_userId, _token: ${_token != null ? "YES" : "NO"}, _lastPeriodStart: $_lastPeriodStart');
    if (_token == null || _token!.isEmpty) {
      _token = ApiService.token;
    }

    if (_userId == null) {
      return;
    }
    if (_token == null) {
      return;
    }
    if (_lastPeriodStart == null) {
      return;
    }

    try {
      final body = jsonEncode({
        'lastPeriodStart':
            '${_lastPeriodStart!.year}-${_lastPeriodStart!.month.toString().padLeft(2, '0')}-${_lastPeriodStart!.day.toString().padLeft(2, '0')}',
        'cycleLength': _cycleLength,
        'periodLength': _periodLength,
      });
      print('🔴 BODY SENT: $body');

      final response = await http.post(
        Uri.parse('https://couple-api.liara.run/api/period/setup'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        _isSetupDone = true;
      } else {}
    } catch (e) {
      debugPrint('❌ Error saving period: $e');
    }
    notifyListeners();
  }

  // 🔹 برای بروزرسانی UI
  void loadData() {
    loadFromServer();
  }

  // ===== تنظیمات =====
  void setLastPeriodStart(Jalali date) {
    final now = Jalali.now();
    if (date.toDateTime().isAfter(now.toDateTime())) return;

    _lastPeriodStart = date;

    notifyListeners();
  }

  void setCycleLength(int length) {
    if (length < 21 || length > 35) return;
    _cycleLength = length;
    notifyListeners();
  }

  void setPeriodLength(int length) {
    if (length < 3 || length > 10) return;
    _periodLength = length;
    notifyListeners();
  }

  // 🔥 ذخیره نهایی (دکمه "ذخیره و شروع")
  void setSetupDone(bool done) async {
    if (_lastPeriodStart == null) {
      return;
    }

    _isSetupDone = done;

    if (_token == null || _token!.isEmpty) {
      _token = ApiService.token;
    }

    notifyListeners();

    if (done) {
      await saveToServer();
      // سرور خودش notify می‌ده - نیازی به SocketService.send نیست
    }
  }

  // ===== تاریخچه علائم (فعلاً Hive محلی) =====
  // ===== تاریخچه علائم =====
  Future<void> addSymptomLog(SymptomLog log) async {
    // 🔥 async اضافه شد
    final existingIndex = _history.indexWhere((item) =>
        item.date.year == log.date.year &&
        item.date.month == log.date.month &&
        item.date.day == log.date.day);

    await saveSymptomToServer(log); // 🔥 حالا می‌تونی await کنی

    if (existingIndex != -1) {
      _history[existingIndex] = log;
    } else {
      _history.insert(0, log);
    }
    _periodBox.put(
        '${_userId}_history', _history.map((e) => e.toJson()).toList());

    notifyListeners();
  }

  void deleteSymptomLog(int index) {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    _periodBox.put(
        '${_userId}_history', _history.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  List<SymptomLog> getSymptomsForMonth(int month, int year) {
    return _history.where((log) {
      return log.date.month == month && log.date.year == year;
    }).toList();
  }

  void clearAll() {
    _lastPeriodStart = null;
    _cycleLength = 28;
    _periodLength = 5;
    _isSetupDone = false;
    _history.clear();
    _periodBox.clear();
    notifyListeners();
  }

  // 🔥 متد برای تقویم - تاریخ‌های پریود پارتنر
  List<Jalali> getPartnerPeriodDatesForMonth(int month, int year) {
    if (_partnerLastPeriodStart == null) return [];
    final periodDates = <Jalali>[];
    final start = _partnerLastPeriodStart!;
    for (int i = 0; i < _partnerPeriodLength; i++) {
      final day = start.addDays(i);
      if (day.month == month && day.year == year) {
        periodDates.add(day);
      }
    }
    return periodDates;
  }

// 🔥 متد برای تقویم - پیش‌بینی پریود بعدی پارتنر
  List<Jalali> getPartnerPredictedPeriodDatesForMonth(int month, int year) {
    if (_partnerLastPeriodStart == null) return [];
    final predictedDates = <Jalali>[];
    final nextStart = _partnerLastPeriodStart!.addDays(_partnerCycleLength);
    for (int i = 0; i < _partnerPeriodLength; i++) {
      final periodDay = nextStart.addDays(i);
      if (periodDay.month == month && periodDay.year == year) {
        predictedDates.add(periodDay);
      }
    }
    return predictedDates;
  }

  // 🔥 باروری پارتنر
  List<Jalali> getPartnerFertileDatesForMonth(int month, int year) {
    if (_partnerLastPeriodStart == null) return [];
    final fertileDates = <Jalali>[];
    final ovDay = _partnerCycleLength - 14;
    final ovulationDate = _partnerLastPeriodStart!.addDays(ovDay - 1);
    for (int i = -5; i <= 1; i++) {
      final fertileDay = ovulationDate.addDays(i);
      if (fertileDay.month == month && fertileDay.year == year) {
        fertileDates.add(fertileDay);
      }
    }
    return fertileDates;
  }

// 🔥 تخمک‌گذاری پارتنر
  Jalali? getPartnerOvulationDateForMonth(int month, int year) {
    if (_partnerLastPeriodStart == null) return null;
    final ovDay = _partnerCycleLength - 14;
    final ovulationDate = _partnerLastPeriodStart!.addDays(ovDay - 1);
    if (ovulationDate.month == month && ovulationDate.year == year) {
      return ovulationDate;
    }
    return null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    SocketService.removeHandler(_handleSocketMessage);
    super.dispose();
  }
}
