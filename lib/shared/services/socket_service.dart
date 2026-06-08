import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter/foundation.dart';

typedef MessageHandler = void Function(Map<String, dynamic> message);

class SocketService {
  static WebSocketChannel? _channel;
  static StreamSubscription? _subscription;
  static String? _currentRoomId;
  static bool _isConnecting = false;

  static final List<MessageHandler> _handlers = [];
  static MessageHandler? onMessage;

  static final List<void Function()> _reconnectCallbacks = [];

  static bool get isConnected => _channel != null;

  static void addHandler(MessageHandler handler) {
    if (!_handlers.contains(handler)) _handlers.add(handler);
  }

  static void removeHandler(MessageHandler handler) {
    _handlers.remove(handler);
  }

  static void addReconnectCallback(void Function() callback) {
    _reconnectCallbacks.add(callback);
  }

  static void removeReconnectCallback(void Function() callback) {
    _reconnectCallbacks.remove(callback);
  }

  static void clearHandlers() {
    _handlers.clear();
    onMessage = null;
  }

  // ────── اتصال با توکن و اتاق درست ──────
  static void connect({
    required String token,
    required String roomId,
  }) {
    // اگر از قبل با همین اتاق وصلیم و در حال اتصال نیستیم، کاری نکن
    if (_channel != null && _currentRoomId == roomId && !_isConnecting) {
      debugPrint('🔌 Already connected to $roomId – skipping reconnect');
      return;
    }

    // فقط اگر اتاق واقعاً عوض شده، قبلی رو ببند
    if (_currentRoomId != null && _currentRoomId != roomId) {
      _forceDisconnect();
    }

    _currentRoomId = roomId;
    _isConnecting = true;

    try {
      final uri =
          Uri.parse('wss://couple-api.liara.run').replace(queryParameters: {
        'token': token,
        'room': roomId,
      });

      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            for (final handler in _handlers) {
              handler(message);
            }
            onMessage?.call(message);
          } catch (e) {
            debugPrint('❌ Socket error: $e');
          }
        },
        onError: (error) {
          debugPrint('❌ Socket onError – will retry');
          _channel = null;
          _subscription?.cancel();
          _subscription = null;
          _isConnecting = false;
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('🔌 Socket onDone – will retry');
          _channel = null;
          _subscription?.cancel();
          _subscription = null;
          _isConnecting = false;
          _scheduleReconnect();
        },
      );

      _isConnecting = false;
      // اتصال موفق بود → به شنونده‌ها خبر بده
      _notifyReconnectCallbacks();
    } catch (e) {
      debugPrint('❌ Socket connect error: $e');
      _isConnecting = false;
      _channel = null;
      _scheduleReconnect();
    }
  }

  // ────── تلاش مجدد خودکار ──────
  static void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentRoomId != null && ApiService.token != null) {
        debugPrint('🔄 SocketService trying to reconnect...');
        connect(token: ApiService.token!, roomId: _currentRoomId!);
      }
    });
  }

  // خبر دادن به همه callbackهایی که منتظر اتصال مجدد هستن
  static void _notifyReconnectCallbacks() {
    for (final cb in _reconnectCallbacks) {
      cb();
    }
  }

  static void _forceDisconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
    // توجه: _currentRoomId رو اینجا null نکن تا reconnect بدونه کجا وصل بشه
  }

  static void updateMessageHandler(MessageHandler? handler) {
    onMessage = handler;
  }

  static void sendInvitation({
    required String partnerId,
    required String hostName,
    required String roomId,
    required String videoUrl,
  }) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode({
      'action': 'send_invitation',
      'partnerId': partnerId,
      'hostName': hostName,
      'roomId': roomId,
      'videoUrl': videoUrl,
    }));
  }

  static void send(String action, {Map<String, dynamic>? data}) {
    if (_channel == null) return;
    final message = {'action': action, if (data != null) ...data};
    _channel!.sink.add(jsonEncode(message));
  }

  static void close() {
    _forceDisconnect();
    _currentRoomId = null;
  }

  static void dispose() {
    close();
    clearHandlers();
  }
}
