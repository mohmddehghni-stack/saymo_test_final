import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class RegistrationProvider extends ChangeNotifier {
  // ===== مقادیر =====
  String _displayName = '';
  String _username = '';
  String _phone = '';
  String _password = '';
  String _confirmPassword = '';
  String _userId = '';
  String _partnerId = '';
  String _gender = 'male'; // ← اضافه شده
  int _currentStep = 0;

  // ===== Getterها =====
  String get displayName => _displayName;
  String get username => _username;
  String get phone => _phone;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get userId => _userId;
  String get partnerId => _partnerId;
  String get gender => _gender; // ← اضافه شده
  int get currentStep => _currentStep;

  // ===== Setterها =====
  void setDisplayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void setGender(String value) {
    // ← اضافه شده
    _gender = value;
    notifyListeners();
  }

  void setUserId(String value) {
    _userId = value;
    notifyListeners();
  }

  void setPartnerId(String value) {
    _partnerId = value;
    notifyListeners();
  }

  void setCurrentStep(int value) {
    _currentStep = value;
    notifyListeners();
  }

  // ===== اعتبارسنجی =====
  bool get isStep1Valid => _displayName.trim().length >= 2;

  bool get isStep2Valid =>
      _phone.trim().startsWith('09') && _phone.trim().length == 11;

  bool get isStep3Valid => _password.trim().length >= 6;

  // ===== مراحل =====
  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
}
