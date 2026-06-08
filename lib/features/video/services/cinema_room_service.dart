import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../shared/services/api_service.dart';
import '../../../shared/services/socket_service.dart';

enum RoomStatus {
  disconnected,
  connecting,
  waitingForPartner,
  partnerReady,
  starting,
}

class CinemaRoomService extends ChangeNotifier {
  final String userId;
  final String? partnerId;
  final String? partnerDisplayName;

  String? _currentRoomId;
  String? _partnerName;
  String? _videoUrl;

  RoomStatus _status = RoomStatus.disconnected;
  RoomStatus get status => _status;

  bool _isPartnerOnline = false;
  bool get isPartnerOnline => _isPartnerOnline;

  bool _isPartnerReady = false;
  bool get isPartnerReady => _isPartnerReady;

  bool _isHostReady = false;
  bool get isHostReady => _isHostReady;

  bool _isWatching = false;
  bool get isWatching => _isWatching;

  bool get isConnected => SocketService.isConnected;
  String? get currentRoomId => _currentRoomId;
  String? get partnerName => _partnerName;
  String? get videoUrl => _videoUrl;
  bool get hasPartner => partnerId != null;
  bool get bothReady => _isHostReady && _isPartnerReady;

  VoidCallback? onStartCinema;
  VoidCallback? onPartnerJoined;
  VoidCallback? onPartnerLeft;
  VoidCallback? onPartnerReadyChanged;
  VoidCallback? onVideoSelected;
  VoidCallback? onPartnerReconnected;
  VoidCallback? onPartnerDisconnected;

  CinemaRoomService({
    required this.userId,
    this.partnerId,
    this.partnerDisplayName,
  }) {
    _partnerName = partnerDisplayName ?? partnerId ?? 'پارتنر';
    SocketService.addHandler(_handleSocketMessage);
    if (partnerId != null) {
      _connectToCoupleRoom();
    }
    SocketService.addReconnectCallback(_onSocketReconnect);
  }

  String get _coupleRoomId {
    if (partnerId == null) return 'cinema_$userId';
    final ids = [userId, partnerId!]..sort();
    return 'couple_${ids[0]}_${ids[1]}';
  }

  // 🔥 اتصال به روم (بدون قطع و وصل اضافی)
  Future<void> _connectToCoupleRoom() async {
    if (partnerId == null) return;

    _currentRoomId = _coupleRoomId;
    _status = RoomStatus.waitingForPartner;

    final token = ApiService.token;
    if (token == null) {
      debugPrint('❌ Cannot connect to room: missing token');
      return;
    }

    SocketService.connect(token: token, roomId: _currentRoomId!);

    // اعلام حضور خودم
    sendWithData('partner_online', {
      'userId': userId,
      'isReady': _isHostReady,
      'partnerId': partnerId,
      'hostName': _partnerName ?? userId,
      'isOnline': true,
    });

    // درخواست وضعیت پارتنر (فوری)
    sendWithData('check_partner_status', {
      'userId': userId,
      'partnerId': partnerId,
    });

    // 🔥 یه بار دیگه بعد از ۱ ثانیه وضعیت رو چک کن (برای رفع Race Condition)
    Future.delayed(const Duration(seconds: 1), () {
      if (SocketService.isConnected) {
        sendWithData('check_partner_status', {
          'userId': userId,
          'partnerId': partnerId,
        });
      }
    });

    notifyListeners();
  }

  Future<void> reconnect() async {
    await _connectToCoupleRoom();
    // بعد از وصل شدن، وضعیت آماده بودن رو دوباره بگیر
    sendWithData('check_partner_status', {
      'userId': userId,
      'partnerId': partnerId,
    });
    // ویدئو رو هم دوباره بگیر
    sendWithData('get_room_info', {'roomId': _currentRoomId});
  }

  void _onSocketReconnect() {
    debugPrint('🔄 CinemaRoomService: Socket reconnected');
    _connectToCoupleRoom();
  }

  Future<void> selectVideo(String videoUrl, String videoTitle) async {
    _videoUrl = videoUrl;
    sendWithData('video_selected', {
      'videoUrl': videoUrl,
      'videoTitle': videoTitle,
      'selectedBy': userId,
    });
    notifyListeners();
    onVideoSelected?.call();
  }

  void setHostReady(bool ready) {
    _isHostReady = ready;
    sendWithData('ready_status', {'userId': userId, 'isReady': ready});
    notifyListeners();
    if (bothReady) _startCinema();
  }

  void setWatching(bool watching) {
    _isWatching = watching;
    notifyListeners();
  }

  void _startCinema() {
    _status = RoomStatus.starting;
    send('start_cinema');
    notifyListeners();
    onStartCinema?.call();
  }

  void notifyDisconnect() {
    sendWithData('user_disconnected', {
      'userId': userId,
      'isWatching': _isWatching,
    });
  }

  void notifyReconnect() {
    sendWithData('user_reconnected', {'userId': userId});
    _connectToCoupleRoom();
  }

  // 🔥 مدیریت پیام‌های Socket (تصحیح‌شده)
  void _handleSocketMessage(Map<String, dynamic> message) {
    final action = message['action'] as String?;
    debugPrint('📩 CinemaRoomService: $action');

    switch (action) {
      case 'partner_online':
        // 🔥 همینکه این پیام اومد یعنی پارتنر آنلاینه
        _isPartnerOnline = true;
        _isPartnerReady = message['isReady'] == true;
        if (_partnerName == null || _partnerName!.isEmpty) {
          _partnerName =
              message['hostName']?.toString() ?? partnerId ?? 'پارتنر';
        }
        _status = RoomStatus.partnerReady;
        onPartnerJoined?.call();
        onPartnerReadyChanged?.call();
        notifyListeners();
        break;

      case 'partner_status':
        _isPartnerOnline = message['isOnline'] == true;
        _isPartnerReady = message['isReady'] == true;
        onPartnerReadyChanged?.call();
        notifyListeners();
        break;

      case 'partner_left':
      case 'partner_disconnected':
        _isPartnerOnline = false;
        _isPartnerReady = false;
        _status = RoomStatus.waitingForPartner;
        onPartnerDisconnected?.call();
        onPartnerReadyChanged?.call();
        notifyListeners();
        break;

      case 'partner_reconnected':
        _isPartnerOnline = true;
        _isPartnerReady = false;
        _status = RoomStatus.partnerReady;
        onPartnerReconnected?.call();
        onPartnerReadyChanged?.call();
        notifyListeners();
        break;

      case 'ready_status':
        _isPartnerReady = message['isReady'] == true;
        onPartnerReadyChanged?.call();
        notifyListeners();
        break;

      case 'video_selected':
        _videoUrl = message['videoUrl']?.toString();
        onVideoSelected?.call();
        notifyListeners();
        break;

      case 'room_info':
        _videoUrl = message['videoUrl']?.toString();
        if (_videoUrl != null && _videoUrl!.isNotEmpty) {
          onVideoSelected?.call();
        }
        notifyListeners();
        break;

      case 'start_cinema':
        _status = RoomStatus.starting;
        notifyListeners();
        onStartCinema?.call();
        break;
    }
  }

  void send(String action) {
    if (!SocketService.isConnected) return;
    SocketService.send(action);
  }

  void sendWithData(String action, Map<String, dynamic> data) {
    if (!SocketService.isConnected) return;
    SocketService.send(action, data: data);
  }

  Future<void> leaveRoom() async {
    send('leave_room');
    _currentRoomId = null;
    _videoUrl = null;
    _status = RoomStatus.disconnected;
    _isPartnerOnline = false;
    _isPartnerReady = false;
    _isHostReady = false;
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService.removeReconnectCallback(_onSocketReconnect);
    SocketService.removeHandler(_handleSocketMessage);
    onStartCinema = null;
    onPartnerJoined = null;
    onPartnerLeft = null;
    onPartnerReadyChanged = null;
    onVideoSelected = null;
    onPartnerReconnected = null;
    onPartnerDisconnected = null;
    super.dispose();
  }
}
