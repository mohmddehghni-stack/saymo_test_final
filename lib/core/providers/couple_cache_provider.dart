import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoupleCacheProvider extends ChangeNotifier {
  late Box _cache;
  int _missYouCount = 0;
  int get missYouCount => _missYouCount;
  int _myMissYouCount = 0;
  int get myMissYouCount => _myMissYouCount;

  String _partnerFeeling = '';
  String _lastMissYou = '';
  List<Map<String, dynamic>> _letters = [];

  String get partnerFeeling => _partnerFeeling;
  String get lastMissYou => _lastMissYou;
  List<Map<String, dynamic>> get letters => List.unmodifiable(_letters);
  bool get hasNewLetters => _letters.isNotEmpty;

  Future<void> _loadMissYouFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/couple/miss-you/count'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _myMissYouCount = data['myTodayCount'] ?? 0;
        _missYouCount = data['partnerTodayCount'] ?? 0;
        _cache.put('my_miss_you_count', _myMissYouCount);
        _cache.put('miss_you_count', _missYouCount);
        notifyListeners();
      }
    } catch (e) {}
  }

  CoupleCacheProvider() {
    _init();
  }

  void _init() {
    _cache = Hive.box('couple_cache');
    _loadFromCache();
    _loadMissYouFromServer();
    SocketService.addHandler(_handleSocketMessage);
  }

  void _loadFromCache() {
    _partnerFeeling =
        _cache.get('partner_feeling', defaultValue: '')?.toString() ?? '';
    _lastMissYou =
        _cache.get('last_miss_you', defaultValue: '')?.toString() ?? '';

    // 🔥 myMissYouCount - بدون ریست
    final myCount = _cache.get('my_miss_you_count');
    if (myCount != null && myCount is num && !myCount.isNaN) {
      _myMissYouCount = myCount.toInt();
    } else {
      _myMissYouCount = 0;
    }

    // 🔥 ریست روزانه فقط برای missYouCount (مال پارتنر)
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastDate =
        _cache.get('miss_you_date', defaultValue: '')?.toString() ?? '';

    if (lastDate != today) {
      _missYouCount = 0;
      _myMissYouCount = 0; // 🔥 اینم صفر کن
      _cache.put('miss_you_date', today);
      _cache.put('miss_you_count', 0);
      _cache.put('my_miss_you_count', 0); // 🔥
    } else {
      final count = _cache.get('miss_you_count');
      if (count != null && count is num && !count.isNaN) {
        _missYouCount = count.toInt();
      } else {
        _missYouCount = 0;
      }
    }

    notifyListeners();
  }

  Future<void> refreshMissYouCounts() async {
    await _loadMissYouFromServer();
  }

  void incrementMyMissYou() {
    _myMissYouCount++;
    _cache.put('my_miss_you_count', _myMissYouCount);
    notifyListeners();
  }

  void _handleSocketMessage(Map<String, dynamic> data) {
    switch (data['action']) {
      case 'feeling_received':
        _partnerFeeling = data['feeling'] ?? '';
        _cache.put('partner_feeling', _partnerFeeling);
        notifyListeners();
        break;

      case 'miss_you_received':
        _missYouCount = data['count'] ?? (_missYouCount + 1);
        _lastMissYou = DateTime.now().toString();
        _cache.put('miss_you_count', _missYouCount);
        _cache.put('last_miss_you', _lastMissYou);
        notifyListeners();
        break;

      case 'love_letter_received':
        _cache.put('has_new_letter', true);
        notifyListeners();
        break;
    }
  }

  void markLettersRead() {
    _cache.put('has_new_letter', false);
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleSocketMessage);
    super.dispose();
  }
}
