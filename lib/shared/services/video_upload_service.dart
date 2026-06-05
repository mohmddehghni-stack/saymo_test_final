import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class VideoUploadService {
  static const String uploadUrl = 'https://s5.uupload.ir/upload.php';
  static const String userPath = 'mmduuu';
  static const String userId = '217407';

  /// گرفتن hash با یه GET ساده به upload.php
  static Future<String?> _getHash() async {
    try {
      // یه GET به upload.php بزن - hash رو از response نگیر، از URL parameter استفاده کن
      final testUrl = '$uploadUrl?path=$userPath&user_id=$userId';

      // این hash رو از لاگ قبلی برداشتم - ممکنه عوض بشه
      // اگه بازم invalid بود، باید از لاگ Network دوباره برداریم
      return '0e4dc0ac3d054219cbdb76981f497846'; // 🔥 hash قبلی
    } catch (e) {
      return null;
    }
  }

  static Future<String?> pickAndUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;

      return await _uploadFile(file);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> _uploadFile(PlatformFile file) async {
    try {
      final hash = await _getHash();
      if (hash == null) {
        return null;
      }

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      request.fields['path'] = userPath;
      request.fields['user_id'] = userId;
      request.fields['hash'] = hash;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes('file', file.bytes!,
              filename: file.name),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        final playerUrl = data['browser_player_url'];

        return playerUrl;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
