import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

class SyncService {
  static late Box _queueBox;
  static Timer? _syncTimer;
  static bool _isSyncing = false;
  static StreamSubscription? _connectivitySubscription;

  /// راه‌اندازی - توی main.dart بعد از Hive.init صدا بزن
  static Future<void> init() async {
    _queueBox = Hive.box('sync_queue');

    // گوش دادن به تغییرات اینترنت
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        // آنلاین شدیم - صف رو پردازش کن
        processQueue();
      }
    });

    // هر ۱۵ ثانیه چک کن
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      processQueue();
    });

    // همون اول هم چک کن
    processQueue();

    debugPrint('🔄 SyncService initialized - Queue: ${pendingCount} items');
  }

  /// اضافه کردن عملیات به صف
  static Future<void> enqueue({
    required String method, // POST, PUT, PATCH, DELETE
    required String endpoint, // /shared-notes, /calendar/notes
    required Map<String, dynamic> body,
    String? note, // توضیح برای دیباگ
  }) async {
    final item = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'method': method,
      'endpoint': endpoint,
      'body': body,
      'note': note ?? '$method $endpoint',
      'timestamp': DateTime.now().toIso8601String(),
      'retries': 0,
    };

    final queue = _getQueue();
    queue.add(item);
    await _saveQueue(queue);

    debugPrint('📦 Enqueued: ${item['note']} (Queue: ${queue.length})');

    // سعی کن همون لحظه sync کنه
    processQueue();
  }

  /// پردازش صف
  static Future<void> processQueue() async {
    if (_isSyncing) return;

    final queue = _getQueue();
    if (queue.isEmpty) return;

    _isSyncing = true;
    debugPrint('🔄 Processing sync queue (${queue.length} items)...');

    final failedItems = <Map<String, dynamic>>[];

    for (final item in queue) {
      try {
        final success = await _sendRequest(item);
        if (success) {
          debugPrint('✅ Synced: ${item['note']}');
        } else {
          failedItems.add(_incrementRetry(item));
        }
      } catch (e) {
        debugPrint('❌ Error syncing ${item['note']}: $e');
        failedItems.add(_incrementRetry(item));
      }
    }

    // فقط آیتم‌های ناموفق بمونن (حداکثر ۵ بار تلاش)
    final validItems =
        failedItems.where((item) => (item['retries'] as int) < 5).toList();
    await _saveQueue(validItems);
    _isSyncing = false;

    if (validItems.isNotEmpty) {
      debugPrint('⚠️ ${validItems.length} items pending');
    } else if (failedItems.isNotEmpty) {
      debugPrint(
          '🗑️ ${failedItems.length - validItems.length} items discarded (max retries)');
    }
  }

  /// ارسال درخواست HTTP
  static Future<bool> _sendRequest(Map<String, dynamic> item) async {
    final url = Uri.parse('${ApiService.baseUrl}${item['endpoint']}');
    final headers = {
      'Content-Type': 'application/json',
      if (ApiService.token != null)
        'Authorization': 'Bearer ${ApiService.token}',
    };
    final body = jsonEncode(item['body']);

    http.Response response;
    switch (item['method']) {
      case 'POST':
        response = await http.post(url, headers: headers, body: body);
        break;
      case 'PUT':
        response = await http.put(url, headers: headers, body: body);
        break;
      case 'PATCH':
        response = await http.patch(url, headers: headers, body: body);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers, body: body);
        break;
      default:
        return false;
    }

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// گرفتن صف
  static List<Map<String, dynamic>> _getQueue() {
    final raw = _queueBox.get('pending_sync', defaultValue: []) as List;
    return raw.cast<Map<String, dynamic>>().toList();
  }

  /// ذخیره صف
  static Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    await _queueBox.put('pending_sync', queue);
  }

  /// افزایش تعداد تلاش
  static Map<String, dynamic> _incrementRetry(Map<String, dynamic> item) {
    item['retries'] = (item['retries'] as int) + 1;
    return item;
  }

  /// تعداد آیتم‌های در صف
  static int get pendingCount => _getQueue().length;

  /// پاک کردن صف
  static Future<void> clearQueue() async {
    await _queueBox.put('pending_sync', []);
    debugPrint('🗑️ Sync queue cleared');
  }

  /// آزادسازی منابع
  static void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}
