import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../services/cinema_room_service.dart';
import 'video_watch_ui_page.dart';
import 'package:flutter_application_1/shared/services/video_upload_service.dart';
import 'package:flutter_application_1/shared/widgets/user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';

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

  late AnimationController _pulseController;
  late AnimationController _seatAnimController;

  final List<Map<String, String>> _suggestedVideos = [
    {
      'title': 'Big Buck Bunny 🐰',
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
    SocketService.addReconnectCallback(_onSocketReconnect);

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
  }

  void _onSocketReconnect() {
    _roomService.notifyReconnect();
  }

  void _onRoomStateChanged() {
    if (!mounted) return;
    setState(() {
      _isPartnerReady = _roomService.isPartnerReady;
      _isHostReady = _roomService.isHostReady;
      _isCountdownStarted = false;
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
    _roomService.setWatching(false);
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
    SocketService.removeReconnectCallback(_onSocketReconnect);
    _roomService.removeListener(_onRoomStateChanged);
    _pulseController.dispose();
    _seatAnimController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // 🔥 دکمه عمومی (جایگزین سه دکمه تکراری)
  // ──────────────────────────────────────────────
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isSmall ? 16 : 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(text,
                  style: TextStyle(
                      color: color,
                      fontSize: isSmall ? 13 : 14,
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 🎬 انتخاب فیلم (BottomSheet)
  // ──────────────────────────────────────────────
  void _showVideoSelectorSheet() {
    final urlController = TextEditingController(); // 👈 لوکال

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
                    controller: urlController,
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
                    if (urlController.text.isNotEmpty) {
                      _selectVideo(urlController.text, 'فیلم انتخابی');
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

  // ──────────────────────────────────────────────
  // 🎭 خروج از سینما
  // ──────────────────────────────────────────────
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

  // ──────────────────────────────────────────────
  // 📱 UI اصلی
  // ──────────────────────────────────────────────
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final isSmallScreen = maxHeight < 700;

              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 24, vertical: isSmallScreen ? 8 : 16),
                child: Column(
                  children: [
                    // دکمه برگشت
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _showExitDialog(),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white70, size: 20)),
                      ),
                    ),

                    // محتوای اصلی
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // لوگو
                          Container(
                            width: isSmallScreen ? 70 : 90,
                            height: isSmallScreen ? 70 : 90,
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
                            child: Center(
                                child: Text('🍿',
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 36 : 44))),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // عنوان
                          FittedBox(
                            child: const Text('سینمای دونفره',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontFamily: 'Vazir',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 10),

                          // وضعیت آنلاین
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
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
                                const SizedBox(width: 6),
                                Text(
                                    _isPartnerReady
                                        ? 'آنلاین'
                                        : 'منتظر پارتنر...',
                                    style: TextStyle(
                                        color: _isPartnerReady
                                            ? Colors.greenAccent
                                                .withOpacity(0.9)
                                            : Colors.orangeAccent
                                                .withOpacity(0.9),
                                        fontSize: 12,
                                        fontFamily: 'Vazir')),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // صندلی‌ها
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 👤 صندلی کاربر
                              _buildUserSeat(
                                isOnline: true,
                                isSmall: isSmallScreen,
                              ),
                              SizedBox(width: isSmallScreen ? 30 : 50),
                              // 👤 صندلی پارتنر
                              _buildPartnerSeat(
                                isOnline: _isPartnerReady,
                                isSmall: isSmallScreen,
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // پیام
                          if (_isCountdownStarted)
                            _buildCountdown(isSmall: isSmallScreen)
                          else if (_isPartnerReady && hasVideo)
                            _buildReadyMessage(isSmall: isSmallScreen)
                          else
                            _buildWaitingMessage(),
                          SizedBox(height: isSmallScreen ? 12 : 20),

                          // دکمه‌ها
                          if (!_isCountdownStarted) ...[
                            if (hasVideo && _roomService.isWatching)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildContinueWatchingButton(
                                    isSmall: isSmallScreen),
                              ),
                            _buildActionButton(
                              text: hasVideo
                                  ? 'فیلم انتخاب شد ✅'
                                  : 'انتخاب فیلم 🎥',
                              icon: hasVideo ? Icons.check_circle : Icons.movie,
                              color: hasVideo
                                  ? Colors.greenAccent
                                  : Colors.white70,
                              onTap: _showVideoSelectorSheet,
                              isSmall: isSmallScreen,
                            ),
                            const SizedBox(height: 6),
                            _buildActionButton(
                              text: 'آپلود فیلم خودم 📁',
                              icon: Icons.upload_file,
                              color: Colors.orangeAccent,
                              onTap: () async {
                                // ... کد آپلود
                              },
                              isSmall: isSmallScreen,
                            ),
                            const SizedBox(height: 6),
                            _buildReadyButton(isSmall: isSmallScreen),
                          ],
                        ],
                      ),
                    ),

                    // Footer
                    if (!_isCountdownStarted)
                      Padding(
                        padding: EdgeInsets.only(bottom: isSmallScreen ? 4 : 8),
                        child: Text(
                            hasVideo
                                ? 'هر دو آماده باشین تا سینما شروع بشه ✨'
                                : 'اول یه فیلم انتخاب کن 🎬',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 11,
                                fontFamily: 'Vazir')),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 👤 صندلی کاربر (خودم)
// 👤 صندلی کاربر (خودم)
  Widget _buildUserSeat({required bool isOnline, bool isSmall = false}) {
    final appProvider = context.read<AppProvider>();
    final size = isSmall ? 65.0 : 80.0;
    final avatarUrl = appProvider.avatarUrl;
    final gender = appProvider.gender ?? 'male';
    final displayName = appProvider.displayName ?? appProvider.username ?? 'من';

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOnline
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: isOnline
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildLottieAvatar(gender, size),
                  )
                : _buildLottieAvatar(gender, size),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isOnline
                ? AppColors.primary.withOpacity(0.15)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            displayName,
            style: TextStyle(
              color: isOnline ? Colors.white : Colors.white54,
              fontSize: isSmall ? 12 : 14,
              fontFamily: 'Vazir',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6), blurRadius: 6)
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('آنلاین',
            style: TextStyle(
                color: Colors.greenAccent.withOpacity(0.8),
                fontSize: 10,
                fontFamily: 'Vazir')),
      ],
    );
  }

// 👤 صندلی پارتنر
  Widget _buildPartnerSeat({required bool isOnline, bool isSmall = false}) {
    final appProvider = context.read<AppProvider>();
    final size = isSmall ? 65.0 : 80.0;
    final partnerAvatarUrl = appProvider.partnerAvatarUrl;
    final partnerGender = appProvider.partnerGender ?? 'male';
    final partnerDisplayName = appProvider.partnerDisplayName ??
        appProvider.partnerUsername ??
        'پارتنر';

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isOnline
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: isOnline
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: partnerAvatarUrl != null && partnerAvatarUrl.isNotEmpty
                ? Image.network(
                    partnerAvatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildLottieAvatar(partnerGender, size),
                  )
                : _buildLottieAvatar(partnerGender, size),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isOnline
                ? AppColors.primary.withOpacity(0.15)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            partnerDisplayName,
            style: TextStyle(
              color: isOnline ? Colors.white : Colors.white54,
              fontSize: isSmall ? 12 : 14,
              fontFamily: 'Vazir',
              fontWeight: FontWeight.w500,
            ),
          ),
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
                : [],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isOnline ? 'آنلاین' : 'آفلاین',
          style: TextStyle(
            color: isOnline
                ? Colors.greenAccent.withOpacity(0.8)
                : Colors.grey.shade600,
            fontSize: 10,
            fontFamily: 'Vazir',
          ),
        ),
      ],
    );
  }

// 🎭 انیمیشن Lottie برای وقتی عکس نداری
  Widget _buildLottieAvatar(String gender, double size) {
    final asset = gender == 'female'
        ? 'assets/lottie/female_avatar.json'
        : 'assets/lottie/male_avatar.json';

    return Container(
      color: gender == 'female'
          ? const Color(0xFFFFE0E8)
          : const Color(0xFFE0EAFF),
      child: Center(
        child: Lottie.asset(
          asset,
          width: size * 1,
          height: size * 1,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // ⏳ ویجت‌های کمکی
  // ──────────────────────────────────────────────
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

  Widget _buildReadyMessage({bool isSmall = false}) {
    return Column(
      children: [
        Icon(Icons.check_circle_rounded,
            color: Colors.greenAccent, size: isSmall ? 24 : 32),
        SizedBox(height: isSmall ? 8 : 12),
        const Text('پارتنرت آنلاینه! 🎉',
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontFamily: 'Vazir',
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildReadyButton({bool isSmall = false}) {
    final bool hostReady = _roomService.isHostReady;
    final bool partnerReady = _roomService.isPartnerReady;

    return GestureDetector(
      onTap: _toggleHostReady,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isSmall ? 14 : 18),
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
                    color: Colors.white, size: isSmall ? 22 : 24),
                const SizedBox(width: 8),
                Text(hostReady ? 'آماده‌ام ✅' : 'آماده شو 🎬',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 16 : 18,
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

  Widget _buildCountdown({bool isSmall = false}) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 3, end: 1),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) => Column(
        children: [
          Text('🎬', style: TextStyle(fontSize: isSmall ? 40 : 56)),
          SizedBox(height: isSmall ? 10 : 16),
          Text('$value',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 60 : 80,
                  fontFamily: 'Vazir',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(color: AppColors.primary, blurRadius: 20)
                  ])),
          SizedBox(height: isSmall ? 8 : 12),
          const Text('سینما در حال شروع...',
              style: TextStyle(
                  color: Colors.white54, fontSize: 14, fontFamily: 'Vazir')),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingButton({bool isSmall = false}) {
    return GestureDetector(
      onTap: () {
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
        padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.purpleAccent, Colors.deepPurple]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled,
                color: Colors.white, size: isSmall ? 22 : 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text('🎬 ادامه تماشای ویدیو',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 15 : 18,
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
