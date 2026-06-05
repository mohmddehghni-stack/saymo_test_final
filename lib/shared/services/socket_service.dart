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
    }
  }

  // 👈 حذف کردن هندلر
  static void removeHandler(MessageHandler handler) {
    _handlers.remove(handler);
  }

  // 👈 پاک کردن همه هندلرها
  static void clearHandlers() {
    _handlers.clear();
    onMessage = null;
  }

  static void connect({required String userId, String roomId = 'default'}) {
    if (_currentRoomId != null && _currentRoomId != roomId) {
      _forceDisconnect();
    }

    if (_channel != null &&
        _currentUserId == userId &&
        _currentRoomId == roomId) {
      return;
    }

    if (_isConnecting) {
      return;
    }

    _forceDisconnect();

    _currentUserId = userId;
    _currentRoomId = roomId;
    _isConnecting = true;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://couple-api.liara.run?userId=$userId&room=$roomId'),
      );

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);

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
          _forceDisconnect();
        },
        onDone: () {
          _forceDisconnect();
        },
      );

      _isConnecting = false;
    } catch (e) {
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
  }

  static void sendInvitation({
    required String partnerId,
    required String hostName,
    required String roomId,
    required String videoUrl,
  }) {
    if (_channel == null) {
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
      return;
    }

    final message = {
      'action': action,
      if (data != null) ...data,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  static void close() {
    _forceDisconnect();
    _currentUserId = null;
    _currentRoomId = null;
  }

  // 👈 پاکسازی کامل
  static void dispose() {
    close();
    clearHandlers();
  }
}
