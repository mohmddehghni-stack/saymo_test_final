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
  }

  String get _coupleRoomId {
    if (partnerId == null) return 'cinema_$userId';
    final ids = [userId, partnerId!]..sort();
    return 'couple_${ids[0]}_${ids[1]}';
  }

  // 🔥 اتصال به روم - بدون Delay
  Future<void> _connectToCoupleRoom() async {
    if (partnerId == null) return;

    _currentRoomId = _coupleRoomId;
    _status = RoomStatus.waitingForPartner;

    final token = ApiService.token; // 🔥 توکن رو از ApiService بگیر
    if (token == null) {
      debugPrint('❌ Cannot connect to room: missing token');
      return;
    }

    SocketService.connect(token: token, roomId: _currentRoomId!);

    // 🔥 بلافاصله بعد از connect
    sendWithData('get_room_info', {'roomId': _currentRoomId});
    sendWithData(
        'check_partner_status', {'userId': userId, 'partnerId': partnerId});
    sendWithData('partner_online', {
      'userId': userId,
      'isReady': _isHostReady,
      'partnerId': partnerId,
      'hostName': _partnerName ?? userId,
    });

    notifyListeners();
  }

  Future<void> selectVideo(String videoUrl, String videoTitle) async {
    _videoUrl = videoUrl;
    sendWithData('video_selected', {
      'videoUrl': videoUrl,
      'videoTitle': videoTitle,
      'selectedBy': userId,
    });
    SocketService.send('update_room_info', data: {'videoUrl': videoUrl});
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

  // 🔥 مدیریت پیام‌های Socket - ادغام شده
  void _handleSocketMessage(Map<String, dynamic> message) {
    final action = message['action'] as String?;
    debugPrint('📩 CinemaRoomService: $action');

    switch (action) {
      // 🔥 ادغام partner_online و partner_status
      case 'partner_online':
      case 'partner_status':
        _isPartnerOnline = message['isOnline'] == true ||
            message['isReady'] == true ||
            message['isReady'] == true;
        _isPartnerReady = message['isReady'] == true;
        if (_partnerName == null || _partnerName!.isEmpty) {
          _partnerName =
              message['partnerName']?.toString() ?? partnerId ?? 'پارتنر';
        }
        _status = _isPartnerOnline
            ? RoomStatus.partnerReady
            : RoomStatus.waitingForPartner;
        if (_isPartnerOnline) onPartnerJoined?.call();
        onPartnerReadyChanged?.call();
        notifyListeners();
        break;

      // 🔥 ادغام partner_left و partner_disconnected
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

  // 🔥 خروج از روم - بدون بستن Socket
  Future<void> leaveRoom() async {
    send('leave_room'); // فقط پیام بفرست
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
