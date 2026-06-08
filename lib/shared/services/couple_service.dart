import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
import 'package:flutter/material.dart';

class CoupleService {
  static const String baseUrl = ApiService.baseUrl;

  /// 💌 ارسال نامه عاشقانه
  static Future<bool> sendLoveLetter(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/couple/love-letter'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SocketService.send('love_letter_sent', data: {'text': text});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Love letter error: $e');
      return false;
    }
  }

  /// 😊 ارسال حس و حال (جایگزین sendFeeling)
  /// 😊 ارسال حس و حال به سرور (Mood)
  static Future<bool> sendMood(String mood,
      {int intensity = 3, String? note}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/couple/mood'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({
          'mood': mood,
          'intensity': intensity,
          'note': note,
        }),
      );

      if (response.statusCode == 201) {
        SocketService.send('mood_sent', data: {'mood': mood});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Mood error: $e');
      return false;
    }
  }

  /// 💕 ارسال "دلم تنگ شده"
  static Future<int?> sendMissYou() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/couple/miss-you'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        SocketService.send('miss_you_sent', data: {});
        return data['todayCount'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ Miss you error: $e');
      return null;
    }
  }

  /// 📍 بروزرسانی موقعیت
  static Future<bool> updateLocation(double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/couple/location'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({'lat': lat, 'lng': lng}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Location update error: $e');
      return false;
    }
  }

  /// 📏 گرفتن فاصله (جایگزین getPartnerLocation)
  static Future<double?> getDistance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/couple/distance'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['distance'] as num?)?.toDouble();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get distance error: $e');
      return null;
    }
  }
}
