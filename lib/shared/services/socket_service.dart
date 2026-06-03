import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef MessageHandler = void Function(Map<String, dynamic> message);

class SocketService {
  static WebSocketChannel? _channel;
  static StreamSubscription? _subscription;
  static String? _currentUserId;
  static String? _currentRoomId;
  static bool _isConnecting = false;

  // 👈 لیست هندلرها (برای پشتیبانی از چندتا listener)
  static final List<MessageHandler> _handlers = [];

  // 👈 برای backward compatibility
  static MessageHandler? onMessage;

  static bool get isConnected => _channel != null;

  // 👈 اضافه کردن هندلر
  static void addHandler(MessageHandler handler) {
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
      print('🔌 هندلر اضافه شد (${_handlers.length} عدد)');
    }
  }

  // 👈 حذف کردن هندلر
  static void removeHandler(MessageHandler handler) {
    _handlers.remove(handler);
    print('🔌 هندلر حذف شد (${_handlers.length} عدد)');
  }

  // 👈 پاک کردن همه هندلرها
  static void clearHandlers() {
    _handlers.clear();
    onMessage = null;
    print('🔌 همه هندلرها پاک شدن');
  }

  static void connect({required String userId, String roomId = 'default'}) {
    if (_currentRoomId != null && _currentRoomId != roomId) {
      print('🔄 تغییر اتاق از $_currentRoomId به $roomId');
      _forceDisconnect();
    }

    if (_channel != null &&
        _currentUserId == userId &&
        _currentRoomId == roomId) {
      print('🟡 قبلاً به همین اتاق وصله');
      return;
    }

    if (_isConnecting) {
      print('⏳ connection قبلی هنوز در حال اتصاله');
      return;
    }

    _forceDisconnect();

    _currentUserId = userId;
    _currentRoomId = roomId;
    _isConnecting = true;

    print('🔵 در حال اتصال به WebSocket...');

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://couple-api.liara.run?userId=$userId&room=$roomId'),
      );

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            print('📩 پیام: ${message['action']}');

            // 👈 فراخوانی همه هندلرها
            for (final handler in _handlers) {
              handler(message);
            }

            // 👈 backward compatibility
            onMessage?.call(message);
          } catch (e) {
            print('❌ خطا: $e');
          }
        },
        onError: (error) {
          print('🔴 WebSocket error: $error');
          _forceDisconnect();
        },
        onDone: () {
          print('🔴 WebSocket closed');
          _forceDisconnect();
        },
      );

      _isConnecting = false;
      print('✅ اتصال موفق');
    } catch (e) {
      print('❌ خطا: $e');
      _isConnecting = false;
      _forceDisconnect();
    }
  }

  static void _forceDisconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
  }

  // 👈 آپدیت هندلر (برای backward compatibility)
  static void updateMessageHandler(MessageHandler? handler) {
    onMessage = handler;
    print('🔄 هندلر اصلی آپدیت شد');
  }

  static void sendInvitation({
    required String partnerId,
    required String hostName,
    required String roomId,
    required String videoUrl,
  }) {
    if (_channel == null) {
      print('❌ وب‌سوکت وصل نیست');
      return;
    }

    _channel!.sink.add(jsonEncode({
      'action': 'send_invitation',
      'partnerId': partnerId,
      'hostName': hostName,
      'roomId': roomId,
      'videoUrl': videoUrl,
    }));
  }

  // 👈 send با data اضافی
  static void send(String action, {Map<String, dynamic>? data}) {
    if (_channel == null) {
      print('❌ وب‌سوکت وصل نیست');
      return;
    }

    final message = {
      'action': action,
      if (data != null) ...data,
    };

    print('📤 ارسال: $action');
    _channel!.sink.add(jsonEncode(message));
  }

  static void close() {
    print('🔴 بستن وب‌سوکت...');
    _forceDisconnect();
    _currentUserId = null;
    _currentRoomId = null;
    print('✅ وب‌سوکت بسته شد');
  }

  // 👈 پاکسازی کامل
  static void dispose() {
    close();
    clearHandlers();
  }
}
