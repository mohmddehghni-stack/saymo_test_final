import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static late Box _periodBox;
  static late Box _userBox;

  /// مقداردهی اولیه - توی main.dart صدا بزن
  static Future<void> init() async {
    _periodBox = Hive.box('period_data');
    _userBox = Hive.box('user_data');
  }

  // ========== جنسیت ==========
  static String getGender() {
    return _userBox.get('gender', defaultValue: 'female');
  }

  static Future<void> setGender(String gender) async {
    await _userBox.put('gender', gender);
  }

  // ========== پریود ==========
  static String? getLastPeriodStart(String userId) {
    return _periodBox.get('${userId}_lastPeriodStart');
  }

  static Future<void> setLastPeriodStart(String userId, String value) async {
    await _periodBox.put('${userId}_lastPeriodStart', value);
  }

  static int getCycleLength(String userId) {
    return _periodBox.get('${userId}_cycleLength', defaultValue: 28);
  }

  static Future<void> setCycleLength(String userId, int value) async {
    await _periodBox.put('${userId}_cycleLength', value);
  }

  static int getPeriodLength(String userId) {
    return _periodBox.get('${userId}_periodLength', defaultValue: 5);
  }

  static Future<void> setPeriodLength(String userId, int value) async {
    await _periodBox.put('${userId}_periodLength', value);
  }

  static bool isSetupDone(String userId) {
    return _periodBox.get('${userId}_isSetupDone', defaultValue: false);
  }

  static Future<void> setSetupDone(String userId, bool value) async {
    await _periodBox.put('${userId}_isSetupDone', value);
  }

  // ========== پاک کردن ==========
  static Future<void> clearAll() async {
    await _periodBox.clear();
    await _userBox.clear();
  }
}
