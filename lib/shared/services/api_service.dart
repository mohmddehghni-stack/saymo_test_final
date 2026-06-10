import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class ApiService {
  static const String baseUrl = 'https://couple-api.liara.run/api';

  static String? _token;
  static String? currentUserId;
  static String? _coupleId; // 🔥 جدید

  // ─────────────────────────────────────────
  // 🔥 لود اطلاعات از Hive (موقع شروع برنامه)
  // ─────────────────────────────────────────
  static Future<void> init() async {
    final box = Hive.box('user_data');
    _token = box.get('token');
    currentUserId = box.get('userId');
    _coupleId = box.get('coupleId'); // 🔥 جدید
    print('🔑 Token loaded: ${_token != null ? "YES" : "NO"}');
    print('🆔 Couple ID loaded: $_coupleId');
  }

  // ─────────────────────────────────────────
  // 🔥 ذخیره اطلاعات (هم رم + هم Hive)
  // ─────────────────────────────────────────
  static Future<void> setToken(String? token,
      {String? userId, String? coupleId}) async {
    _token = token;
    if (userId != null) currentUserId = userId;
    if (coupleId != null) _coupleId = coupleId; // 🔥 جدید

    final box = Hive.box('user_data');
    if (token != null) {
      await box.put('token', token);
    } else {
      await box.delete('token');
    }
    if (userId != null) {
      await box.put('userId', userId);
    }
    if (coupleId != null) {
      await box.put('coupleId', coupleId); // 🔥 جدید
    }
  }

  // ─────────────────────────────────────────
  // 🔥 حذف اطلاعات (موقع خروج از حساب)
  // ─────────────────────────────────────────
  static Future<void> clearToken() async {
    _token = null;
    currentUserId = null;
    _coupleId = null; // 🔥 جدید
    final box = Hive.box('user_data');
    await box.delete('token');
    await box.delete('userId');
    await box.delete('coupleId'); // 🔥 جدید
  }

  // ─────────────────────────────────────────
  static String? get token => _token;
  static String? get coupleId => _coupleId; // 🔥 جدید

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
  static Map<String, String> get headers => _headers;

  // ────── احراز هویت ──────

  static Future<Map<String, dynamic>> register(
    String displayName,
    String username,
    String phone,
    String password,
    String gender,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'displayName': displayName,
        'username': username,
        'phone': phone,
        'password': password,
        'gender': gender,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<bool> isPhoneAvailable(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/check-phone'),
      headers: _headers,
      body: jsonEncode({'phone': phone}),
    );
    final data = jsonDecode(response.body);
    return data['available'] == true;
  }

  static Future<bool> isUsernameAvailable(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/check-username'),
      headers: _headers,
      body: jsonEncode({'username': username.toLowerCase()}),
    );
    final data = jsonDecode(response.body);
    return data['available'] == true;
  }

  static Future<Map<String, dynamic>> login(
    String login,
    String password,
  ) async {
    final isEmail = login.contains('@');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        if (isEmail) 'email': login else 'username': login,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // ────── پروفایل و اتصال ──────

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> connectPartner(
      String partnerPublicId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/connect'),
      headers: _headers,
      body: jsonEncode({'partnerPublicId': partnerPublicId}),
    );
    return jsonDecode(response.body);
  }

  // ────── چت (اصلاح‌شده) ──────

  static Future<Map<String, dynamic>> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
      body: jsonEncode({'text': text}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    return data['messages'] ?? [];
  }

  // ────── یادداشت‌ها ──────

  static Future<Map<String, dynamic>> saveNote(
    int day,
    int month,
    int year,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: _headers,
      body: jsonEncode({
        'day': day,
        'month': month,
        'year': year,
        'text': text,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    return data['notes'] ?? [];
  }

  // ارسال کد OTP
  static Future<Map<String, dynamic>> sendOTP(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(response.body);
  }

  // تایید کد OTP
  static Future<Map<String, dynamic>> verifyOTP(
      String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    return jsonDecode(response.body);
  }

  /// ورود با OTP (برای کاربران قدیمی)
  static Future<Map<String, dynamic>> loginWithOTP(
      String phone, String code) async {
    // ابتدا کد را تایید می‌کنیم
    final verifyResult = await verifyOTP(phone, code);
    if (verifyResult['message'] == null) {
      return verifyResult; // خطا برگشت
    }

    // حالا چون کاربر قدیمی است، با رمز پیش‌فرض لاگین می‌کنیم
    // (چون ثبت‌نام قبلی با رمز ساده انجام شده بود)
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': '123456', // رمز پیش‌فرض که توی ثبت‌نام استفاده کردیم
      }),
    );
    return jsonDecode(response.body);
  }
}
