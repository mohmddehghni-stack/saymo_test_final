import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shamsi_date/shamsi_date.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../shared/services/socket_service.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

enum SyncStatus { idle, syncing, synced, error }

class CalendarProvider extends ChangeNotifier {
  String? userId;
  String? partnerId;
  String? userGender;
  // 🔥 Polling حذف شد
  bool _isLoadingNotes = false; // جلوگیری از فراخوانی همزمان

  final Map<String, Map<String, dynamic>> _savedNotes = {};
  final Map<String, int> _selectedDaysPerMonth = {};

  Jalali _selectedDate = Jalali.now();

  bool _isLoading = false;
  String? _errorMessage;
  SyncStatus _syncStatus = SyncStatus.idle;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SyncStatus get syncStatus => _syncStatus;

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

  static const List<String> _weekDays = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  int _normalizeWeekDay(int weekDay) => weekDay == 7 ? 6 : weekDay - 1;

  Map<String, Map<String, dynamic>> get savedNotesWithFullKey =>
      Map.unmodifiable(_savedNotes);

  Map<int, Map<String, dynamic>> get savedNotes {
    final result = <int, Map<String, dynamic>>{};
    for (final entry in _savedNotes.entries) {
      try {
        final parts = entry.key.split('-');
        if (parts.length == 3 &&
            int.parse(parts[0]) == selectedYear &&
            int.parse(parts[1]) == selectedMonth) {
          result[int.parse(parts[2])] = entry.value;
        }
      } catch (e) {}
    }
    return result;
  }

  Set<int> get noteDays {
    final days = <int>{};
    for (final key in _savedNotes.keys) {
      try {
        final parts = key.split('-');
        if (parts.length == 3 &&
            int.parse(parts[0]) == selectedYear &&
            int.parse(parts[1]) == selectedMonth) {
          days.add(int.parse(parts[2]));
        }
      } catch (e) {}
    }
    return days;
  }

  int get selectedMonth => _selectedDate.month;
  int get selectedYear => _selectedDate.year;
  int get daysInMonth => _selectedDate.monthLength;

  int get startDay {
    final wd = Jalali(_selectedDate.year, _selectedDate.month, 1).weekDay;
    return _normalizeWeekDay(wd);
  }

  String get monthName => _monthNames[_selectedDate.month - 1];
  String get weekDayName => _weekDays[_normalizeWeekDay(_selectedDate.weekDay)];

  int? get todayDay {
    final now = Jalali.now();
    return (now.year == selectedYear && now.month == selectedMonth)
        ? now.day
        : null;
  }

  int? get selectedDay {
    final key = '${_selectedDate.year}-${_selectedDate.month}';
    if (_selectedDaysPerMonth.containsKey(key))
      return _selectedDaysPerMonth[key];
    final now = Jalali.now();
    return (now.year == selectedYear && now.month == selectedMonth)
        ? now.day
        : null;
  }

  List<int> get sortedNoteDays {
    final days = noteDays.toList();
    days.sort((a, b) => b.compareTo(a));
    return days;
  }

  // =============================================
  // 🔥 سازنده - بدون Polling
  // =============================================
  CalendarProvider({this.userId, this.partnerId}) {
    try {
      final box = Hive.box('user_data');
      userGender = box.get('gender', defaultValue: 'female');
    } catch (e) {
      userGender = 'female';
    }
    SocketService.addHandler(_handleSocketMessage);
    if (userId != null && partnerId != null) {
      _loadNotesSilent();
    }
  }

  void updateUserIds({String? userId, String? partnerId}) {
    if (this.userId != userId || this.partnerId != partnerId) {
      this.userId = userId;
      this.partnerId = partnerId;
      if (userId != null && partnerId != null) {
        _loadNotesSilent();
      }
    }
  }

  void changeMonth(int year, int month) {
    final newMonthLength = Jalali(year, month, 1).monthLength;
    final key = '$year-$month';
    final day = _selectedDaysPerMonth[key] ?? 1;
    _selectedDate = Jalali(year, month, day.clamp(1, newMonthLength));
    notifyListeners();
  }

  void selectDay(int day) {
    final maxDay = _selectedDate.monthLength;
    final safeDay = day.clamp(1, maxDay);
    final key = '${_selectedDate.year}-${_selectedDate.month}';
    _selectedDaysPerMonth[key] = safeDay;
    _selectedDate = Jalali(_selectedDate.year, _selectedDate.month, safeDay);
    notifyListeners();
  }

  String formatDate(int day) {
    final maxDay = _selectedDate.monthLength;
    final safeDay = day.clamp(1, maxDay);
    final date = Jalali(_selectedDate.year, _selectedDate.month, safeDay);
    final diff = date.toDateTime().difference(Jalali.now().toDateTime()).inDays;
    String diffText;
    if (diff == 0) {
      diffText = 'امروز';
    } else if (diff > 0) {
      diffText = '$diff روز بعد';
    } else {
      diffText = '${-diff} روز قبل';
    }
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year} - $diffText';
  }

  String _makeKey({int? year, int? month, int? day}) {
    final y = year ?? selectedYear;
    final m = month ?? selectedMonth;
    final d = day ?? selectedDay;
    return '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
  }

  // =============================================
  // 🔥 WebSocket Handler - جایگزین Polling
  // =============================================
  void _handleSocketMessage(Map<String, dynamic> data) {
    print('📩 CalendarProvider got: ${data['action']}');
    if (data['action'] == 'calendar_note_added' ||
        data['action'] == 'calendar_note_update' ||
        data['action'] == 'calendar_note_updated' ||
        data['action'] == 'calendar_note_deleted') {
      // ← اینو داری؟
      print('🔄 reloading notes...');
      _loadNotesSilent().then((_) => notifyListeners());
    }
  }

  // =============================================
  // 🔥 لود بی‌صدا - با debounce
  // =============================================
  Future<void> _loadNotesSilent() async {
    if (userId == null || partnerId == null) return;
    if (_isLoadingNotes) return;
    _isLoadingNotes = true;

    try {
      final uri = Uri.parse(
          'https://couple-api.liara.run/api/calendar/notes?userId=$userId&partnerId=$partnerId');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${ApiService.token}',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notes = data['notes'] as Map<String, dynamic>?;

        // 🔥 اول کل یادداشت‌ها رو پاک کن
        _savedNotes.clear();

        // بعد با داده جدید پر کن
        if (notes != null && notes.isNotEmpty) {
          notes.forEach((key, dayData) {
            _savedNotes[key] = Map<String, dynamic>.from(dayData as Map);
          });
        }

        // 🔥 همیشه notify کن
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ _loadNotesSilent error: $e');
    } finally {
      _isLoadingNotes = false;
    }
  }

  // =============================================
  // 🔥 CRUD Operations - همه با Auth
  // =============================================
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        if (ApiService.token != null)
          'Authorization': 'Bearer ${ApiService.token}',
      };

  Future<void> addNote(int day, String text,
      {bool isPrivate = false, bool isRecurring = false}) async {
    if (userId == null || partnerId == null) return;
    final key = _makeKey(day: day);
    final previousState = _savedNotes[key] != null
        ? Map<String, dynamic>.from(_savedNotes[key]!)
        : null;

    _savedNotes[key] ??= {};
    _savedNotes[key]![userId!] = {
      'note': text,
      'userId': userId,
      'isPrivate': isPrivate,
      'isRecurring': isRecurring,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://couple-api.liara.run/api/calendar/notes'),
        body: jsonEncode({
          'userId': userId,
          'partnerId': partnerId,
          'day': day,
          'month': selectedMonth,
          'year': selectedYear,
          'note': text
        }),
        headers: _authHeaders,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _syncStatus = SyncStatus.synced;

        // 🔥 اینو برگردون:
        SocketService.send('calendar_note_added', data: {
          'day': day,
          'note': text,
          'userId': userId,
        });
      } else {
        _rollbackNote(key, previousState);
        _errorMessage = 'خطا در ذخیره یادداشت';
        _syncStatus = SyncStatus.error;
      }
    } catch (e) {
      _rollbackNote(key, previousState);
      _errorMessage = 'خطا در اتصال به سرور';
      _syncStatus = SyncStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateNote(int day, String newText) async {
    if (userId == null || partnerId == null) return;
    final key = _makeKey(day: day);
    if (!_savedNotes.containsKey(key) || !_savedNotes[key]!.containsKey(userId))
      return;
    if (_savedNotes[key]![userId]!['note']?.toString() == newText) return;

    final previousState = Map<String, dynamic>.from(_savedNotes[key]!);
    _savedNotes[key]![userId!] = {
      'note': newText,
      'userId': userId,
      'updatedAt': DateTime.now().toIso8601String()
    };
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://couple-api.liara.run/api/calendar/notes'),
        body: jsonEncode({
          'userId': userId,
          'partnerId': partnerId,
          'day': day,
          'month': selectedMonth,
          'year': selectedYear,
          'note': newText
        }),
        headers: _authHeaders,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _syncStatus = SyncStatus.synced;

        // 🔥 اضافه کن:
        SocketService.send('calendar_note_updated', data: {
          'day': day,
          'note': newText,
          'userId': userId,
        });
      } else {
        _savedNotes[key] = previousState;
        _errorMessage = 'خطا در ویرایش یادداشت';
        _syncStatus = SyncStatus.error;
      }
    } catch (e) {
      _savedNotes[key] = previousState;
      _errorMessage = 'خطا در اتصال به سرور';
      _syncStatus = SyncStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteNote(int day) async {
    if (userId == null) return;
    final key = _makeKey(day: day);
    if (!_savedNotes.containsKey(key) || !_savedNotes[key]!.containsKey(userId))
      return;

    final previousState = Map<String, dynamic>.from(_savedNotes[key]!);
    _savedNotes[key]!.remove(userId);
    if (_savedNotes[key]!.isEmpty) _savedNotes.remove(key);
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('https://couple-api.liara.run/api/calendar/notes'),
        body: jsonEncode({'userId': userId, 'day': day}),
        headers: _authHeaders,
      );
      if (response.statusCode == 200) {
        _syncStatus = SyncStatus.synced;

        // 🔥 اضافه کن:
        SocketService.send('calendar_note_deleted', data: {
          'day': day,
          'userId': userId,
        });
      } else {
        _savedNotes[key] = previousState;
        _errorMessage = 'خطا در حذف یادداشت';
        _syncStatus = SyncStatus.error;
      }
    } catch (e) {
      _savedNotes[key] = previousState;
      _errorMessage = 'خطا در اتصال به سرور';
      _syncStatus = SyncStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void _rollbackNote(String key, Map<String, dynamic>? previousState) {
    if (previousState != null) {
      _savedNotes[key] = previousState;
    } else {
      _savedNotes[key]?.remove(userId);
      if (_savedNotes[key]?.isEmpty ?? false) _savedNotes.remove(key);
    }
  }

  String? getNote(int day) =>
      _savedNotes[_makeKey(day: day)]?[userId]?['note']?.toString();
  String? getPartnerNote(int day) =>
      _savedNotes[_makeKey(day: day)]?[partnerId]?['note']?.toString();
  bool hasNote(int day) => _savedNotes.containsKey(_makeKey(day: day));

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> forceRefresh() async {
    await _loadNotesSilent();
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleSocketMessage);
    super.dispose();
  }
}
