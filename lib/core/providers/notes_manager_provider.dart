import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
import 'package:flutter_application_1/shared/services/sync_service.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🔥 Hive

class NoteItem {
  final int id;
  String text;
  String time;
  bool isMe;
  bool isChecked; // 🔥 برای تیک (خط زدن)
  bool isSelectedForDelete; // 🔥 برای انتخاب حذف
  final DateTime createdAt;

  NoteItem({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.isChecked = false,
    this.isSelectedForDelete = false,
    required this.createdAt,
  });

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String());
    return NoteItem(
      id: json['id'],
      text: json['text'] ?? '',
      time: '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
      isMe: json['user_id'].toString() == ApiService.currentUserId,
      isChecked: json['is_checked'] ?? false,
      isSelectedForDelete: false, // همیشه از سرور false میاد
      createdAt: createdAt,
    );
  }
}

class NotesManagerProvider extends ChangeNotifier {
  List<NoteItem> _allNotes = [];
  String? _coupleId;
  bool _isLoading = false;

  List<NoteItem> get allNotes => List.unmodifiable(_allNotes);
  List<NoteItem> get myNotes =>
      _allNotes.where((n) => n.isMe).toList().reversed.toList();
  List<NoteItem> get partnerNotes =>
      _allNotes.where((n) => !n.isMe).toList().reversed.toList();
  bool get isLoading => _isLoading;

  NotesManagerProvider() {
    _init();
  }

  void _init() {
    // گوش دادن به WebSocket
    SocketService.addHandler(_handleSocketMessage);
  }

  void setup(String userId, String partnerId) {
    // ساخت coupleId یکتا برای زوج
    final ids = [userId, partnerId]..sort();
    _coupleId = ids.join('_');
    ApiService.currentUserId = userId;
    loadNotes();
  }

  void _handleSocketMessage(Map<String, dynamic> data) {
    if (data['action'] == 'shared_note_update') {
      loadNotes(); // هر تغییری از طرف پارتنر اومد، کل لیست رو دوباره بخون
    }
  }

  /// 🔥 انتخاب برای حذف
  void toggleSelectForDelete(int id) {
    final index = _allNotes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _allNotes[index].isSelectedForDelete =
          !_allNotes[index].isSelectedForDelete;
      notifyListeners();
    }
  }

  /// 🔥 ریست کردن انتخاب‌های حذف
  void clearDeleteSelection() {
    for (final note in _allNotes) {
      note.isSelectedForDelete = false;
    }
    notifyListeners();
  }

  Future<void> deleteAllNotes() async {
    try {
      // پاک کردن از سرور (اختیاری - اگه می‌خوای همه رو پاک کنی)
      for (final note in _allNotes.where((n) => n.isMe)) {
        await http.delete(
          Uri.parse('${ApiService.baseUrl}/shared-notes/${note.id}'),
          headers: ApiService.headers,
        );
      }
      await loadNotes();
      _notifyPartner();
    } catch (e) {
      debugPrint('❌ Error deleting all: $e');
    }
  }

  Future<void> loadNotes() async {
    if (_coupleId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/shared-notes'),
        headers: ApiService.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> notesJson = jsonDecode(response.body)['notes'];

        _allNotes = notesJson.map((n) => NoteItem.fromJson(n)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =============================================
// 🔥 اضافه کردن یادداشت (قبلاً انجام شد)
// =============================================
  Future<void> addNote(String text) async {
    if (text.trim().isEmpty || _coupleId == null) return;

    final now = DateTime.now();
    final tempId = now.millisecondsSinceEpoch;

    _allNotes.insert(
        0,
        NoteItem(
          id: tempId,
          text: text,
          time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          isMe: true,
          isChecked: false,
          createdAt: now,
        ));
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/shared-notes'),
        headers: ApiService.headers,
        body: jsonEncode({'text': text}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadNotes();
        _notifyPartner();
        return;
      }
    } catch (e) {
      debugPrint('❌ Offline - adding to queue');
    }

    await SyncService.enqueue(
      method: 'POST',
      endpoint: '/shared-notes',
      body: {'text': text},
      note: 'Add shared note',
    );
  }

// =============================================
// 🔥 ویرایش یادداشت
// =============================================
  Future<void> updateNote(int id, String newText) async {
    // ۱. فوری UI رو آپدیت کن
    final index = _allNotes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _allNotes[index].text = newText;
      notifyListeners();
    }

    try {
      // ۲. مستقیم به سرور
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/shared-notes/$id'),
        headers: ApiService.headers,
        body: jsonEncode({'text': newText}),
      );
      if (response.statusCode == 200) {
        await loadNotes();
        _notifyPartner();
        return;
      }
    } catch (e) {
      debugPrint('❌ Offline - update to queue');
    }

    // ۳.失败 → صف
    await SyncService.enqueue(
      method: 'PUT',
      endpoint: '/shared-notes/$id',
      body: {'text': newText},
      note: 'Update shared note',
    );
  }

// =============================================
// 🔥 تیک زدن (خط زدن) - فقط UI
// =============================================
  void toggleTickLocal(int id) {
    final index = _allNotes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _allNotes[index].isChecked = !_allNotes[index].isChecked;
      notifyListeners();
    }
  }

// =============================================
// 🔥 تیک زدن با API
// =============================================
  Future<void> toggleTickApi(int id) async {
    final index = _allNotes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final newValue = !_allNotes[index].isChecked;

    // ۱. فوری UI
    _allNotes[index].isChecked = newValue;
    notifyListeners();

    try {
      // ۲. مستقیم به سرور
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/shared-notes/$id/toggle'),
        headers: ApiService.headers,
        body: jsonEncode({'isChecked': newValue}),
      );
      if (response.statusCode == 200) {
        await loadNotes();
        _notifyPartner();
        return;
      }
    } catch (e) {
      debugPrint('❌ Offline - toggle to queue');
    }

    // ۳.失败 → صف
    await SyncService.enqueue(
      method: 'PATCH',
      endpoint: '/shared-notes/$id/toggle',
      body: {'isChecked': newValue},
      note: 'Toggle shared note',
    );
  }

// =============================================
// 🔥 حذف یک یادداشت
// =============================================
  Future<void> deleteNote(int id) async {
    // ۱. فوری از UI حذف کن
    _allNotes.removeWhere((n) => n.id == id);
    notifyListeners();

    try {
      // ۲. مستقیم به سرور
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/shared-notes/$id'),
        headers: ApiService.headers,
      );
      if (response.statusCode == 200) {
        await loadNotes();
        _notifyPartner();
        return;
      }
    } catch (e) {
      debugPrint('❌ Offline - delete to queue');
    }

    // ۳.失败 → صف
    await SyncService.enqueue(
      method: 'DELETE',
      endpoint: '/shared-notes/$id',
      body: {},
      note: 'Delete shared note',
    );
  }

// =============================================
// 🔥 حذف انتخاب‌شده‌ها
// =============================================
  Future<void> deleteSelected() async {
    final selectedIds =
        _allNotes.where((n) => n.isSelectedForDelete).map((n) => n.id).toList();
    if (selectedIds.isEmpty) return;

    // ۱. فوری از UI حذف کن
    _allNotes.removeWhere((n) => n.isSelectedForDelete);
    notifyListeners();

    // ۲. برای هر کدوم
    for (final id in selectedIds) {
      try {
        final response = await http.delete(
          Uri.parse('${ApiService.baseUrl}/shared-notes/$id'),
          headers: ApiService.headers,
        );
        if (response.statusCode != 200) {
          await SyncService.enqueue(
            method: 'DELETE',
            endpoint: '/shared-notes/$id',
            body: {},
            note: 'Delete selected note',
          );
        }
      } catch (e) {
        await SyncService.enqueue(
          method: 'DELETE',
          endpoint: '/shared-notes/$id',
          body: {},
          note: 'Delete selected note (offline)',
        );
      }
    }

    await loadNotes();
    _notifyPartner();
  }

  void _notifyPartner() {
    SocketService.send('shared_note_changed', data: {
      'action': 'shared_note_update',
      'coupleId': _coupleId,
    });
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleSocketMessage);
    super.dispose();
  }
}
