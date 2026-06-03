import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart'; // 🔥 اضافه کن

class ApiService {
  static const String baseUrl = 'https://couple-api.liara.run/api';

  static String? _token;
  static String? currentUserId;

  // ─────────────────────────────────────────
  // 🔥 لود توکن از Hive (موقع شروع برنامه)
  // ─────────────────────────────────────────
  static Future<void> init() async {
    final box = Hive.box('user_data');
    _token = box.get('token');
    currentUserId = box.get('userId'); // اگه داری
    print('🔑 Token loaded: ${_token != null ? "YES" : "NO"}');
  }

  // ─────────────────────────────────────────
  // 🔥 ذخیره توکن (هم رم + هم Hive)
  // ─────────────────────────────────────────
  static Future<void> setToken(String? token, {String? userId}) async {
    _token = token;
    if (userId != null) currentUserId = userId;

    final box = Hive.box('user_data');
    if (token != null) {
      await box.put('token', token);
    } else {
      await box.delete('token');
    }
    if (userId != null) {
      await box.put('userId', userId);
    }
  }

  // ─────────────────────────────────────────
  // 🔥 حذف توکن (موقع خروج از حساب)
  // ─────────────────────────────────────────
  static Future<void> clearToken() async {
    _token = null;
    currentUserId = null;
    final box = Hive.box('user_data');
    await box.delete('token');
    await box.delete('userId');
  }

  // ─────────────────────────────────────────
  static String? get token => _token;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
  static Map<String, String> get headers => _headers;

  // ────── بقیه متدها بدون تغییر (از _headers استفاده می‌کنن) ──────

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

  // چک کردن موجود بودن شماره تلفن
  static Future<bool> isPhoneAvailable(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/check-phone'),
      headers: _headers,
      body: jsonEncode({'phone': phone}),
    );
    final data = jsonDecode(response.body);
    return data['available'] == true;
  }

  // 💕 وصل شدن به پارتنر
  static Future<Map<String, dynamic>> connectPartner(
      String partnerPublicId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/connect'),
      headers: _headers,
      body: jsonEncode({'partnerPublicId': partnerPublicId}),
    );
    return jsonDecode(response.body);
  }

  // چک کردن موجود بودن نام کاربری
  static Future<bool> isUsernameAvailable(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/check-username'),
      headers: _headers,
      body: jsonEncode({'username': username.toLowerCase()}),
    );
    final data = jsonDecode(response.body);
    return data['available'] == true;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    return jsonDecode(response.body);
  }

  // 🔓 ورود
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

  // 📝 ذخیره یادداشت
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

  // 📋 دریافت یادداشت‌ها
  static Future<List<dynamic>> getNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    return data['notes'] ?? [];
  }

  // 💬 ارسال پیام
  static Future<Map<String, dynamic>> sendMessage(
    String text,
    String time,
    bool isMe,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
      body: jsonEncode({'text': text, 'time': time, 'isMe': isMe}),
    );
    return jsonDecode(response.body);
  }

  // 📋 دریافت پیام‌ها
  static Future<List<dynamic>> getMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);
    return data['messages'] ?? [];
  }
}
