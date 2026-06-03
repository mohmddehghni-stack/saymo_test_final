import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert'; // برای jsonEncode
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    SocketService.addHandler(_handleSocketMessage);
  }
  int _feelingValue = 0;
  String _moodEmoji = '😊';
  bool _isConnected = false;
  String? _partnerUsername;
  String? _partnerId;
  String? _userId;
  String? _gender;
  String? _username;
  String? _partnerDisplayName;
  String? _displayName;
  bool _isDarkMode = false;
  String? _avatarUrl;
  String? _partnerAvatarUrl;
  String? _partnerGender;

  int get feelingValue => _feelingValue;
  String get moodEmoji => _moodEmoji;
  bool get isConnected => _isConnected;
  String? get partnerUsername => _partnerUsername;
  String? get partnerId => _partnerId;
  String? get userId => _userId;
  String? get gender => _gender;
  String? get username => _username;
  String? get partnerDisplayName => _partnerDisplayName;
  String? get displayName => _displayName;
  bool get isDarkMode => _isDarkMode;
  String? get avatarUrl => _avatarUrl;
  String? get partnerAvatarUrl => _partnerAvatarUrl;
  String? get partnerGender => _partnerGender;

  void incrementFeeling() {
    _feelingValue++;
    notifyListeners();
  }

  void setMood(String emoji) {
    _moodEmoji = emoji;
    notifyListeners();
  }

  void setUsername(String name) async {
    // 🔥 اضافه کن
    _username = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  void logout() async {
    _userId = null;
    _partnerId = null;
    _partnerUsername = null;
    _isConnected = false;
    _gender = null;
    _username = null;
    _displayName = null; // 🔥 اضافه کن
    _partnerDisplayName = null; // 🔥 اضافه کن
    _avatarUrl = null;
    _partnerAvatarUrl = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  void setAvatarUrl(String? url) async {
    _avatarUrl = url;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      await prefs.setString('avatarUrl', url);
    } else {
      await prefs.remove('avatarUrl');
    }
  }

  void connectPartner(
    String username, {
    String? partnerId,
    String? displayName,
    String? partnerGender,
  }) async {
    _isConnected = true;
    _partnerUsername = username;
    _partnerId = partnerId;
    _partnerDisplayName = displayName;
    _partnerGender = partnerGender; // 🔥 اضافه کن
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConnected', true);
    await prefs.setString('partnerUsername', username);
    if (partnerId != null) {
      await prefs.setString('partnerId', partnerId);
    }
    if (displayName != null) {
      await prefs.setString('partnerDisplayName', displayName);
    }
    if (partnerGender != null) {
      await prefs.setString('partnerGender', partnerGender);
    }
  }

  void resetConnection() async {
    _isConnected = false;
    _partnerUsername = null;
    _partnerId = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isConnected', false);
    await prefs.remove('partnerUsername');
    await prefs.remove('partnerId');
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _isConnected = prefs.getBool('isConnected') ?? false;
    _partnerUsername = prefs.getString('partnerUsername');
    _partnerId = prefs.getString('partnerId');
    _userId = prefs.getString('userId');
    _gender = prefs.getString('gender');
    _username = prefs.getString('username');
    _displayName = prefs.getString('displayName');
    _partnerDisplayName = prefs.getString('partnerDisplayName');
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    _partnerGender = prefs.getString('partnerGender');
    notifyListeners();
  }

  void setPartnerAvatarUrl(String? url) async {
    _partnerAvatarUrl = url;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      await prefs.setString('partnerAvatarUrl', url);
    } else {
      await prefs.remove('partnerAvatarUrl');
    }
  }

  void setUserId(String id) async {
    _userId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
  }

  void setPartnerId(String id) async {
    _partnerId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partnerId', id);
  }

  void setGender(String gender) async {
    _gender = gender;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);

    // 🔥 توی Hive هم ذخیره کن
    final userBox = Hive.box('user_data');
    userBox.put('gender', gender);
  }

  // 🔥 متد جدید برای ویرایش پروفایل
  // 🔥 متد جدید برای ویرایش پروفایل
  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? phone,
  }) async {
    try {
      print(
          '🔍 updateProfile called with: displayName=$displayName, username=$username, phone=$phone');

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/auth/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({
          if (displayName != null) 'display_name': displayName,
          if (username != null) 'username': username,
          if (phone != null) 'phone': phone,
        }),
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 Server returned user: ${data['user']}');
        print('🔍 display_name: ${data['user']['display_name']}');
        print('🔍 username: ${data['user']['username']}');

        // 🔥 هر دو رو جداگانه آپدیت کن
        _username = data['user']['username'];
        _displayName = data['user']['display_name'];

        print(
            '🔍 After update - _username: $_username, _displayName: $_displayName');

        // 🔥 تو SharedPreferences هم ذخیره کن
        final prefs = await SharedPreferences.getInstance();
        if (_username != null) await prefs.setString('username', _username!);
        if (_displayName != null)
          await prefs.setString('displayName', _displayName!);

        notifyListeners();
        print('🔍 notifyListeners called - UI should update now');
      } else {
        print('❌ Server error: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
    }
  }

  void setDisplayName(String name) async {
    _displayName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('displayName', name);
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _handleSocketMessage(Map<String, dynamic> data) async {
    // 🔥 async اضافه کن
    print('📩 AppProvider got: ${data['action']}');

    if (data['action'] == 'partner_connected') {
      final d = data['data'] ?? data;
      final partnerUsername = d['partnerUsername'] ?? d['username'] ?? 'پارتنر';
      final partnerId = d['partnerId']?.toString();
      final partnerDisplayName = d['partnerDisplayName'];
      connectPartner(partnerUsername,
          partnerId: partnerId, displayName: partnerDisplayName);
    }

    if (data['action'] == 'avatar_updated') {
      _partnerAvatarUrl = data['data']?['avatarUrl'] ?? data['avatarUrl'];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleSocketMessage);
    super.dispose();
  }
}
