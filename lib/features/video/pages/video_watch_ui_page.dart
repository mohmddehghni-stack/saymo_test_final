import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import '../../../shared/services/socket_service.dart';
import '../services/video_player_manager.dart';
import '../services/cinema_room_service.dart';
import '../widgets/video_player_section.dart';
import '../widgets/video_chat_section.dart';
import '../widgets/video_bottom_bar.dart';
import '../widgets/video_floating_chat.dart';

class VideoWatchUIPage extends StatefulWidget {
  final String partnerName;
  final String? videoUrl;
  final CinemaRoomService? roomService;

  const VideoWatchUIPage({
    super.key,
    this.partnerName = 'عزیزم',
    this.videoUrl,
    this.roomService,
  });

  @override
  State<VideoWatchUIPage> createState() => _VideoWatchUIPageState();
}

class _VideoWatchUIPageState extends State<VideoWatchUIPage> {
  final VideoPlayerManager _playerManager = VideoPlayerManager();
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isFullScreen = false;
  bool _isPartnerOnline = true;
  bool _syncRequested = false;
  final List<String> quickReactions = [
    '😍',
    '😂',
    '😭',
    '❤️',
    '🔥',
    '😱',
    '👍',
    '💔'
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.insert(0, {
        "text": text.trim(),
        "isMe": true,
        "time": _getCurrentTime(),
        "type": "text"
      });
    });
    _controller.clear();
    _scrollToBottom();
    SocketService.send('message', data: {'text': text.trim()});
  }

  void sendReaction(String emoji) {
    setState(() {
      messages.insert(0, {
        "text": emoji,
        "isMe": true,
        "time": _getCurrentTime(),
        "type": "reaction"
      });
    });
    _scrollToBottom();
    SocketService.send('reaction', data: {'emoji': emoji});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    SocketService.addHandler(_handleMessage);

    // 👈 بگو برگشتم
    SocketService.send('user_reconnected', data: {});

    // 👈 درخواست sync ویدیو از پارتنر
    Future.delayed(const Duration(milliseconds: 500), () {
      SocketService.send('request_sync', data: {});
    });

    _playerManager.onError = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در لود فیلم 🥺')),
        );
        Navigator.pop(context);
      }
    };

    _playerManager.onStateChanged = () {
      if (mounted) {
        setState(() {});

        if (_playerManager.isInitialized && !_syncRequested) {
          _syncRequested = true;
          SocketService.send('request_sync', data: {});
        }
      }
    };

    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _playerManager.loadVideo(widget.videoUrl!);
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (!mounted) return;

    switch (data['action']) {
      case 'partner_disconnected':
        setState(() => _isPartnerOnline = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.partnerName} از سینما رفت بیرون 🥺',
                  style: const TextStyle(fontFamily: 'Vazir')),
              backgroundColor: Colors.orangeAccent,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        break;

      case 'partner_reconnected':
        setState(() => _isPartnerOnline = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('پارتنرت برگشت! 🎉',
                  style: TextStyle(fontFamily: 'Vazir')),
              backgroundColor: Colors.greenAccent,
            ),
          );
        }
        break;

      case 'sync_response':
        final syncTime = data['time'];
        final isPlaying = data['isPlaying'] == true;
        if (syncTime != null && _playerManager.isInitialized) {
          final targetPosition =
              Duration(milliseconds: (syncTime * 1000).toInt());
          _playerManager.seekTo(targetPosition, fromRemote: true);
          if (isPlaying && !_playerManager.isPlaying) {
            _playerManager.togglePlay(fromRemote: true);
          }
        }
        break;

      case 'request_sync':
        if (_playerManager.isInitialized) {
          SocketService.send('sync_response', data: {
            'time': _playerManager.position.inSeconds.toDouble(),
            'isPlaying': _playerManager.isPlaying,
          });
        }
        break;

      case 'message':
        setState(() {
          messages.insert(0, {
            "text": data['text'] ?? '',
            "isMe": false,
            "time": _getCurrentTime(),
            "type": "text"
          });
        });
        _scrollToBottom();
        break;

      case 'reaction':
        setState(() {
          messages.insert(0, {
            "text": data['emoji'] ?? '❤️',
            "isMe": false,
            "time": _getCurrentTime(),
            "type": "reaction"
          });
        });
        _scrollToBottom();
        break;

      case 'play':
        _playerManager.togglePlay(fromRemote: true);
        break;

      case 'pause':
        _playerManager.togglePlay(fromRemote: true);
        break;

      case 'seek':
        final time = data['time'];
        if (time != null) {
          final targetPosition = Duration(milliseconds: (time * 1000).toInt());
          final currentPosition = _playerManager.position;
          final diff = (targetPosition - currentPosition).inSeconds.abs();
          if (diff > 0.5) {
            _playerManager.seekTo(targetPosition, fromRemote: true);
          }
        }
        break;

      case 'video_selected':
        final newUrl = data['videoUrl']?.toString();
        if (newUrl != null && newUrl.isNotEmpty) {
          _playerManager.loadVideo(newUrl);
        }
        break;

      case 'partner_left':
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${widget.partnerName} سینما رو ترک کرد 🥺')),
          );
        }
        break;
    }
  }

  void _exitCinema() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B3A),
        title: const Text('خروج از سینما',
            style: TextStyle(color: Colors.white, fontFamily: 'Vazir')),
        content: Text(
            'می‌خوای از سینما خارج بشی؟ ${widget.partnerName} منتظره! 🥺',
            style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontFamily: 'Vazir')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('نه، بمونم',
                style: TextStyle(color: Colors.white70, fontFamily: 'Vazir')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _notifyPartnerAndExit();
            },
            child: const Text('آره، خارج شم',
                style:
                    TextStyle(color: AppColors.primary, fontFamily: 'Vazir')),
          ),
        ],
      ),
    );
  }

  void _notifyPartnerAndExit() async {
    SocketService.send('user_disconnected', data: {'isWatching': true});
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    if (SocketService.isConnected) {
      SocketService.send('user_disconnected', data: {'isWatching': true});
    }
    _controller.dispose();
    _scrollController.dispose();
    _playerManager.dispose();
    SocketService.removeHandler(_handleMessage);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_playerManager.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5)
                  ],
                ),
                child: const Center(
                    child: Text('🍿', style: TextStyle(fontSize: 48))),
              ),
              const SizedBox(height: 24),
              const Text('در حال لود ویدیو... 🎬',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontFamily: 'Vazir')),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.pinkAccent),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (!isFullScreen)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: Colors.black,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _exitCinema,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('🎬 تماشا با ${widget.partnerName}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Vazir')),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isPartnerOnline
                                ? Colors.greenAccent.withOpacity(0.15)
                                : Colors.redAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _isPartnerOnline
                                    ? Colors.greenAccent.withOpacity(0.3)
                                    : Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isPartnerOnline
                                  ? _buildBlinkingDot()
                                  : Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle),
                                    ),
                              const SizedBox(width: 6),
                              Text(_isPartnerOnline ? 'آنلاین' : 'آفلاین',
                                  style: TextStyle(
                                      color: _isPartnerOnline
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 11,
                                      fontFamily: 'Vazir')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                VideoPlayerSection(
                  playerManager: _playerManager,
                  onToggleFullScreen: () =>
                      setState(() => isFullScreen = !isFullScreen),
                  isFullScreen: isFullScreen,
                ),
                if (!isFullScreen) ...[
                  Expanded(
                    child: VideoChatSection(
                        messages: messages,
                        scrollController: _scrollController,
                        videoTitle: widget.partnerName),
                  ),
                  VideoBottomBar(
                    controller: _controller,
                    quickReactions: quickReactions,
                    onSendMessage: sendMessage,
                    onSendReaction: sendReaction,
                  ),
                ],
              ],
            ),
            if (isFullScreen)
              VideoFloatingChat(
                  messages: messages,
                  onExitFullScreen: () => setState(() => isFullScreen = false)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlinkingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 1)
              ],
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isPartnerOnline) setState(() {});
      },
    );
  }
}
