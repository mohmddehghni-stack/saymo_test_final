import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String _phone = '';
  String _code = '';
  String _displayName = '';
  String _gender = 'male';
  String? _publicId;
  bool _isLoading = false;
  String? _errorMessage;

  String get phone => _phone;
  String get code => _code;
  String get displayName => _displayName;
  String get gender => _gender;
  String? get publicId => _publicId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setPhone(String value) {
    _phone = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setPublicId(String? id) {
    _publicId = id;
    notifyListeners();
  }

  void setCode(String value) {
    _code = value;
    notifyListeners();
  }

  Future<String?> loginExistingUserWithOTP() async {
    if (_phone.isEmpty || _code.isEmpty) return null;
    _isLoading = true;
    notifyListeners();
    final result = await ApiService.loginWithOTP(_phone, _code);
    _isLoading = false;
    if (result['token'] != null) {
      return result['token'];
    } else {
      _errorMessage = result['error'] ?? 'خطا در ورود';
      notifyListeners();
      return null;
    }
  }

  void setDisplayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  Future<bool> sendOTP() async {
    if (_phone.length != 11 || !_phone.startsWith('09')) {
      _errorMessage = 'شماره موبایل نامعتبر است';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.sendOTP(_phone);
    _isLoading = false;
    if (result['message'] != null) {
      return true;
    } else {
      _errorMessage = result['error'] ?? 'خطا در ارسال کد';
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyOTP() async {
    if (_code.length < 4) {
      _errorMessage = 'کد باید حداقل ۴ رقم باشد';
      notifyListeners();
      return null;
    }
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.verifyOTP(_phone, _code);
    _isLoading = false;
    if (result['message'] != null) {
      // حالا چک کن کاربر وجود داره یا نه
      final check = await ApiService.isPhoneAvailable(_phone);
      if (check) {
        // کاربر جدید -> برو به تکمیل پروفایل
        return 'new_user';
      } else {
        // کاربر قدیمی -> باید لاگین کنه (با رمز یا OTP)
        return 'existing_user';
      }
    } else {
      _errorMessage = result['error'] ?? 'کد اشتباه است';
      notifyListeners();
      return null;
    }
  }

  Future<String?> registerAndGetToken() async {
    if (_displayName.trim().length < 2) {
      _errorMessage = 'نام نمایشی الزامی است';
      notifyListeners();
      return null;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // ثبت‌نام با نام نمایشی، شماره، رمز پیش‌فرض و جنسیت
    final result = await ApiService.register(
      _displayName,
      _phone, // username = phone
      _phone,
      '123456', // رمز ساده (بعداً می‌تونیم حذفش کنیم)
      _gender,
    );
    _isLoading = false;
    if (result['token'] != null) {
      _publicId = result['user']?['public_id'];
      return result['token'];
    } else {
      _errorMessage = result['error'] ?? 'خطا در ثبت‌نام';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _phone = '';
    _code = '';
    _displayName = '';
    _gender = 'male';
    _publicId = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
