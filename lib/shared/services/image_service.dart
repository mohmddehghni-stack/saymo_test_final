import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // ──────────────────── انتخاب از گالری ────────────────────
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

  // ──────────────────── انتخاب از دوربین ────────────────────
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

  // ──────────────────── فشرده‌سازی هوشمند ────────────────────
  static Future<Uint8List?> compressAvatar(Uint8List bytes) async {
    try {
      // مرحله ۱: فشرده‌سازی با کیفیت ۶۰٪
      var result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: 60,
        minWidth: 512,
        minHeight: 512,
      );

      // مرحله ۲: اگه هنوز > ۲۰۰KB، با کیفیت ۴۰٪
      if (result.length > 200 * 1024) {
        result = await FlutterImageCompress.compressWithList(
          result,
          quality: 40,
          minWidth: 512,
          minHeight: 512,
        );
      }

      if (result.length > 200 * 1024) {
        return null;
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  // ──────────────────── آپلود با Multipart ────────────────────
  // ──────────────────── آپلود با Multipart ────────────────────
  static Future<String?> uploadAvatar(String filePath) async {
    try {
      final bytes = await XFile(filePath).readAsBytes();
      final compressed = await compressAvatar(bytes);
      if (compressed == null) return null;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/upload/avatar'),
      );
      request.headers['Authorization'] = 'Bearer ${ApiService.token}';
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          compressed,
          filename: 'avatar.jpg',
          contentType: http.MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final result = jsonDecode(response.body);
      return result['avatarUrl']; // 👈 سرور Base64 برمیگردونه
    } catch (e) {
      return null;
    }
  }
}
