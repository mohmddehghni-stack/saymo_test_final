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

      if (response.statusCode == 200) {
        SocketService.send('love_letter_sent', data: {'text': text});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Love letter error: $e');
      return false;
    }
  }

  /// 😊 ارسال حس و حال
  static Future<bool> sendFeeling(String feeling) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/couple/feeling'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({'feeling': feeling}),
      );

      if (response.statusCode == 200) {
        SocketService.send('feeling_sent', data: {'feeling': feeling});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Feeling error: $e');
      return false;
    }
  }

  /// 💕 ارسال "دلم تنگ شده"
  static Future<bool> sendMissYou() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/couple/miss-you'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
      );

      if (response.statusCode == 200) {
        SocketService.send('miss_you_sent', data: {});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Miss you error: $e');
      return false;
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

  /// 📥 گرفتن موقعیت پارتنر
  static Future<Map<String, dynamic>?> getPartnerLocation(
      String partnerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/couple/location/$partnerId'),
        headers: {
          'Content-Type': 'application/json',
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Get location error: $e');
      return null;
    }
  }
}
