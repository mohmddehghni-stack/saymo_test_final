import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // ──────────────────── انتخاب از گالری (بدون تغییر) ────────────────────
  static Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  // ──────────────────── انتخاب از دوربین (بدون تغییر) ────────────────────
  static Future<String?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  // ──────────────────── 🆕 فشرده‌سازی هوشمند ────────────────────
  static Future<Uint8List?> compressAvatar(Uint8List bytes) async {
    try {
      print('📸 حجم اولیه: ${(bytes.length / 1024).toStringAsFixed(1)}KB');

      // مرحله ۱: فشرده‌سازی با کیفیت ۶۰٪
      var result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 60,
        minWidth: 512,
        minHeight: 512,
      );
      print('📸 بعد از ۶۰٪: ${(result.length / 1024).toStringAsFixed(1)}KB');

      // مرحله ۲: اگه هنوز > ۲۰۰KB، با کیفیت ۴۰٪
      if (result.length > 200 * 1024) {
        result = await FlutterImageCompress.compressWithList(
          bytes,
          quality: 40,
          minWidth: 512,
          minHeight: 512,
        );
        print('📸 بعد از ۴۰٪: ${(result.length / 1024).toStringAsFixed(1)}KB');
      }

      if (result.length > 200 * 1024) {
        print('❌ هنوز بالای ۲۰۰ کیلوبایته');
        return null;
      }

      return result;
    } catch (e) {
      print('❌ خطا: $e');
      return null;
    }
  }

  // ──────────────────── آپلود (با فشرده‌سازی خودکار) ────────────────────
  static Future<String?> uploadAvatar(String filePath) async {
    try {
      // خوندن فایل
      final bytes = await XFile(filePath).readAsBytes();

      // 🚀 فشرده‌سازی (Web-compatible)
      final compressed = await compressAvatar(bytes);
      if (compressed == null) return null;

      final base64 = 'data:image/jpeg;base64,${base64Encode(compressed)}';

      // 📡 ارسال به سرور (بدون تغییر)
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/upload/avatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({'image': base64}),
      );

      final result = jsonDecode(response.body);
      print('📤 Upload result: $result');
      return result['avatarUrl'];
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }
}
