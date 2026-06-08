import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

typedef MessageHandler = void Function(Map<String, dynamic> message);

class SocketService {
  static WebSocketChannel? _channel;
  static StreamSubscription? _subscription;
  static String? _currentRoomId;
  static bool _isConnecting = false;

  static final List<MessageHandler> _handlers = [];
  static MessageHandler? onMessage;

  static bool get isConnected => _channel != null;

  static void addHandler(MessageHandler handler) {
    if (!_handlers.contains(handler)) _handlers.add(handler);
  }

  static void removeHandler(MessageHandler handler) {
    _handlers.remove(handler);
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
    if (_currentRoomId != null && _currentRoomId != roomId) {
      _forceDisconnect();
    }

    if (_channel != null && _currentRoomId == roomId) return;
    if (_isConnecting) return;

    _forceDisconnect();
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
