import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../services/cinema_room_service.dart';
import 'video_watch_ui_page.dart';
import 'package:flutter_application_1/shared/services/video_upload_service.dart';

class CinemaRoomPage extends StatefulWidget {
  const CinemaRoomPage({super.key});

  @override
  State<CinemaRoomPage> createState() => _CinemaRoomPageState();
}

class _CinemaRoomPageState extends State<CinemaRoomPage>
    with TickerProviderStateMixin {
  late CinemaRoomService _roomService;

  bool _isPartnerReady = false;
  bool _isHostReady = false;
  bool _isCountdownStarted = false;

  final TextEditingController _urlController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _seatAnimController;
  late Animation<double> _seatGlowAnimation;

  final List<Map<String, String>> _suggestedVideos = [
    {
      'title': 'Big Buck Bunny 🐰',
      // یه لینک از یه سرور دیگه که کمتر فیلتره
      'url':
          'https://sample-videos.com/video321/mp4/240/big_buck_bunny_240p_1mb.mp4'
    },
    {
      'title': 'Elephant Dream 🐘',
      'url': 'https://www.w3schools.com/html/mov_bbb.mp4'
    },
    {
      'title': 'Sintel 🐉',
      'url': 'https://filesamples.com/samples/video/mp4/sample_640x360.mp4'
    },
  ];

  @override
  void initState() {
    super.initState();

    final appProvider = context.read<AppProvider>();
    _roomService = CinemaRoomService(
      userId: appProvider.userId ?? '',
      partnerId: appProvider.partnerId,
      partnerDisplayName: appProvider.partnerUsername ?? 'پارتنر',
    );

    _roomService.onStartCinema = () {
      if (mounted) _startCountdown();
    };

    _roomService.onVideoSelected = () {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('پارتنرت یه فیلم انتخاب کرد! 🎬',
                style: TextStyle(fontFamily: 'Vazir')),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    };

    _roomService.onPartnerDisconnected = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('پارتنرت از سینما خارج شد 🥺\nمنتظر برگشتش باش...',
                style: TextStyle(fontFamily: 'Vazir')),
            backgroundColor: Colors.orangeAccent,
            duration: Duration(seconds: 3),
          ),
        );
      }
    };

    _roomService.onPartnerReconnected = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('پارتنرت برگشت! 🎉',
                style: TextStyle(fontFamily: 'Vazir')),
            backgroundColor: Colors.greenAccent,
          ),
        );
      }
    };

    _roomService.onPartnerReadyChanged = () {
      if (mounted) setState(() {});
    };

    _roomService.addListener(_onRoomStateChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _seatAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _seatGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _seatAnimController, curve: Curves.easeInOut),
    );
  }

  void _onRoomStateChanged() {
    if (!mounted) return;
    setState(() {
      _isPartnerReady = _roomService.isPartnerOnline;
      _isHostReady = _roomService.isHostReady;
      _isCountdownStarted = false; // 👈 اینو اضافه کن - همیشه false کن
    });

    if (_roomService.isPartnerOnline) {
      _seatAnimController.forward();
    } else {
      _seatAnimController.reverse();
    }
  }

  void _selectVideo(String url, String title) {
    _roomService.selectVideo(url, title);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('فیلم "$title" انتخاب شد 🎬',
            style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleHostReady() {
    if (_roomService.videoUrl == null || _roomService.videoUrl!.isEmpty) {
      _showVideoSelectorSheet();
      return;
    }

    final newReadyState = !_roomService.isHostReady;
    _roomService.setHostReady(newReadyState);
    setState(() => _isHostReady = newReadyState);
  }

  void _exitRoom() async {
    _roomService.setWatching(false); // ✅ فقط اینجا
    _roomService.notifyDisconnect();
    await _roomService.leaveRoom();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _startCountdown() {
    if (_isCountdownStarted) return;
    setState(() => _isCountdownStarted = true);
    _roomService.setWatching(true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VideoWatchUIPage(
              videoUrl: _roomService.videoUrl ?? '',
              partnerName: _roomService.partnerName ?? 'عزیزم',
              roomService: _roomService,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _roomService.removeListener(_onRoomStateChanged);
    _pulseController.dispose();
    _seatAnimController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2D1B3A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.exit_to_app_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),
              const Text('خارج شدن از سینما',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  'اگه خارج بشی، از سینمای دونفره خارج میشی.\nمطمئنی می‌خوای بری؟ 🥺',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontFamily: 'Vazir')),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Text('نه، بمونم',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontFamily: 'Vazir',
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _exitRoom();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppColors.primary,
                            AppColors.primaryDark
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Text('آره، خارج شم',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Vazir',
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoSelectorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D1B3A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('🎬 انتخاب فیلم',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('فیلم مورد نظرت رو انتخاب کن تا با پارتنرت ببینی 💕',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontFamily: 'Vazir')),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'Vazir'),
                    decoration: InputDecoration(
                      hintText: 'یا لینک فیلم رو بذار...',
                      hintStyle: const TextStyle(
                          color: Colors.white38, fontFamily: 'Vazir'),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      prefixIcon:
                          const Icon(Icons.link, color: Colors.pinkAccent),
                    ),
                    onSubmitted: (url) {
                      if (url.isNotEmpty) {
                        _selectVideo(url, 'فیلم انتخابی');
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_urlController.text.isNotEmpty) {
                      _selectVideo(_urlController.text, 'فیلم انتخابی');
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Colors.pinkAccent,
                          Colors.deepPurpleAccent
                        ]),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('🎥 فیلم‌های پیشنهادی:',
                style: TextStyle(
                    color: Colors.white70, fontSize: 14, fontFamily: 'Vazir')),
            const SizedBox(height: 12),
            ..._suggestedVideos.map((video) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      _selectVideo(video['url']!, video['title']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1))),
                      child: Row(
                        children: [
                          Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Colors.pinkAccent,
                                    Colors.deepPurpleAccent
                                  ]),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(video['title']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Vazir'))),
                          const Icon(Icons.add_circle_outline,
                              color: Colors.white38, size: 20),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final partnerName = appProvider.partnerUsername ?? 'عزیزم';
    final hasVideo =
        _roomService.videoUrl != null && _roomService.videoUrl!.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 0.8,
              colors: [Color(0xFF2D1B3A), Color(0xFF1A0E2A), Colors.black]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showExitDialog(),
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white70, size: 20)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            AppColors.primary,
                            AppColors.primaryDark
                          ]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5)
                          ]),
                      child: const Center(
                          child: Text('🍿', style: TextStyle(fontSize: 48))),
                    ),
                    const SizedBox(height: 24),
                    const Text('سینمای دونفره',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontFamily: 'Vazir',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: _isPartnerReady
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(_isPartnerReady ? 'آنلاین' : 'منتظر پارتنر...',
                              style: TextStyle(
                                  color: _isPartnerReady
                                      ? Colors.greenAccent.withOpacity(0.9)
                                      : Colors.orangeAccent.withOpacity(0.9),
                                  fontSize: 13,
                                  fontFamily: 'Vazir')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCinemaSeat(
                            emoji: '🎭',
                            name: 'تو',
                            isOnline: true,
                            isHost: true),
                        const SizedBox(width: 60),
                        _buildCinemaSeat(
                            emoji: _isPartnerReady ? '😍' : '🎟️',
                            name: partnerName,
                            isOnline: _isPartnerReady,
                            isHost: false),
                      ],
                    ),
                    const SizedBox(height: 40),
                    if (_isCountdownStarted)
                      _buildCountdown()
                    else if (_isPartnerReady && hasVideo)
                      _buildReadyMessage()
                    else
                      _buildWaitingMessage(),
                    const SizedBox(height: 32),

                    // 👈 دکمه‌ها - فقط یه بار
                    if (!_isCountdownStarted) ...[
                      // 👈 دکمه ادامه تماشا
                      if (hasVideo && _roomService.isWatching)
                        _buildContinueWatchingButton(),

                      if (hasVideo && _roomService.isWatching)
                        const SizedBox(height: 12),

                      // 👈 دکمه انتخاب فیلم
                      _buildSelectVideoButton(hasVideo),
                      const SizedBox(height: 12),

                      // 🔥 دکمه آپلود فیلم شخصی
                      _buildUploadVideoButton(),
                      const SizedBox(height: 12),

                      // 👈 دکمه آماده
                      _buildReadyButton(),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (!_isCountdownStarted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                      hasVideo
                          ? 'هر دو آماده باشین تا سینما شروع بشه ✨'
                          : 'اول یه فیلم انتخاب کن 🎬',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontFamily: 'Vazir')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectVideoButton(bool hasVideo) {
    return GestureDetector(
      onTap: _showVideoSelectorSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: hasVideo
              ? Colors.greenAccent.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasVideo
                  ? Colors.greenAccent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasVideo ? Icons.check_circle : Icons.movie,
                color: hasVideo ? Colors.greenAccent : Colors.white54,
                size: 20),
            const SizedBox(width: 10),
            Text(hasVideo ? 'فیلم انتخاب شد ✅' : 'انتخاب فیلم 🎥',
                style: TextStyle(
                    color: hasVideo ? Colors.greenAccent : Colors.white70,
                    fontSize: 15,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaSeat(
      {required String emoji,
      required String name,
      required bool isOnline,
      required bool isHost}) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: isOnline
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : LinearGradient(colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02)
                  ]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isOnline
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: 2),
            boxShadow: isOnline
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12)),
          child: Text(name,
              style: TextStyle(
                  color: isOnline ? Colors.white : Colors.white54,
                  fontSize: 14,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: isOnline ? Colors.greenAccent : Colors.grey.shade700,
              shape: BoxShape.circle,
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.6),
                          blurRadius: 6)
                    ]
                  : []),
        ),
        const SizedBox(height: 4),
        Text(isOnline ? 'آنلاین' : 'آفلاین',
            style: TextStyle(
                color: isOnline
                    ? Colors.greenAccent.withOpacity(0.8)
                    : Colors.grey.shade600,
                fontSize: 10,
                fontFamily: 'Vazir')),
      ],
    );
  }

  Widget _buildWaitingMessage() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) =>
          Opacity(opacity: 0.5 + (_pulseController.value * 0.5), child: child),
      child: const Column(
        children: [
          Icon(Icons.hourglass_bottom_rounded, color: Colors.white38, size: 32),
          SizedBox(height: 12),
          Text('منتظر پارتنرت باش... 💕',
              style: TextStyle(
                  color: Colors.white54, fontSize: 16, fontFamily: 'Vazir')),
        ],
      ),
    );
  }

  Widget _buildReadyMessage() {
    return const Column(
      children: [
        Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 32),
        SizedBox(height: 12),
        Text('پارتنرت آنلاینه! 🎉',
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontFamily: 'Vazir',
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildReadyButton() {
    final bool hostReady = _roomService.isHostReady;
    final bool partnerReady = _roomService.isPartnerReady;

    return GestureDetector(
      onTap: _toggleHostReady,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: hostReady
                  ? [Colors.greenAccent, Colors.green.shade700]
                  : [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: (hostReady ? Colors.greenAccent : AppColors.primary)
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(hostReady ? Icons.check_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(hostReady ? 'آماده‌ام ✅' : 'آماده شو 🎬',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Vazir',
                        fontWeight: FontWeight.bold)),
              ],
            ),
            if (_roomService.isPartnerOnline)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildReadyDot('تو', hostReady),
                    const SizedBox(width: 20),
                    _buildReadyDot(
                        _roomService.partnerName ?? 'پارتنر', partnerReady),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyDot(String name, bool isReady) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: isReady
                    ? Colors.greenAccent
                    : Colors.white.withOpacity(0.3),
                shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(name,
            style: TextStyle(
                color: isReady ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontFamily: 'Vazir')),
      ],
    );
  }

  Widget _buildCountdown() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 3, end: 1),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) => Column(
        children: [
          const Text('🎬', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: AppColors.primary, blurRadius: 20)])),
          const SizedBox(height: 12),
          const Text('سینما در حال شروع...',
              style: TextStyle(
                  color: Colors.white54, fontSize: 14, fontFamily: 'Vazir')),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingButton() {
    return GestureDetector(
      onTap: () {
        // 👈 مستقیم برو به صفحه تماشا
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                VideoWatchUIPage(
              videoUrl: _roomService.videoUrl ?? '',
              partnerName: _roomService.partnerName ?? 'عزیزم',
              roomService: _roomService,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text('🎬 ادامه تماشای ویدیو',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 🔥 دکمه آپلود فیلم شخصی
  Widget _buildUploadVideoButton() {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.orangeAccent),
          ),
        );

        final url = await VideoUploadService.pickAndUpload();

        if (mounted) Navigator.pop(context);

        if (url != null && mounted) {
          _selectVideo(url, 'فیلم شخصی');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ فیلم آپلود شد! پارتنرت رو دعوت کن 🎬'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ آپلود لغو شد یا خطا داد'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, color: Colors.orangeAccent, size: 20),
            SizedBox(width: 10),
            Text('آپلود فیلم خودم 📁',
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 15,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
