import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/side_menu.dart';
import '../../../shared/services/socket_service.dart';
import '../../video/pages/cinema_room_page.dart';
import '../../video/services/cinema_room_service.dart';
import '../../video/widgets/invitation_dialog.dart';
import '../widgets/header.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/connect_banner.dart';
import '../widgets/love_letter.dart';
import '../widgets/suggestion_widget.dart';
import '../widgets/feeling_card.dart';
import '../widgets/miss_you_button.dart';
import '../widgets/location_card.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../core/providers/app_provider.dart';
import 'package:flutter_application_1/shared/widgets/locked_widget.dart';
import '../widgets/body_cards.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _partnerCheckTimer;
  bool _isAppInForeground = true;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final appProvider = context.read<AppProvider>();

    if (appProvider.partnerId != null && appProvider.partnerId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<PeriodProvider>().loadPartnerData();
          context.read<MomentProvider>().loadMoments();
        }
      });
    }

    appProvider.addListener(() {
      if (!mounted) return;
      if (appProvider.partnerId != null && appProvider.partnerId!.isNotEmpty) {
        context.read<PeriodProvider>().loadPartnerData();
        context.read<MomentProvider>().loadMoments();
        _connectToSocket();
        _stopSmartTimer();
      }
    });

    _connectToSocket();
    _tryPullPartner();
    _startSmartTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      _tryPullPartner();
      _startSmartTimer();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MomentProvider>().loadMoments();
          context.read<PeriodProvider>().loadPartnerData();
        }
      });
    } else if (state == AppLifecycleState.paused) {
      _isAppInForeground = false;
      _stopSmartTimer();
    }
  }

  void _startSmartTimer() {
    _stopSmartTimer();
    _partnerCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted || !_isAppInForeground) {
        _stopSmartTimer();
        return;
      }
      final appProvider = context.read<AppProvider>();
      if (appProvider.coupleId != null && appProvider.partnerId != null) {
        _stopSmartTimer();
        return;
      }
      _tryPullPartner();
    });
  }

  void _stopSmartTimer() {
    _partnerCheckTimer?.cancel();
    _partnerCheckTimer = null;
  }

  void _forceStopTimerIfConnected() {
    if (!mounted) return;
    final appProvider = context.read<AppProvider>();
    if (appProvider.partnerId != null) {
      _stopSmartTimer();
    }
  }

  Future<void> _tryPullPartner() async {
    if (!mounted) return;
    final appProvider = context.read<AppProvider>();
    if (appProvider.userId == null) return;

    try {
      final response = await ApiService.getProfile();

      if (response['user']?['couple_id'] != null) {
        appProvider.setCoupleId(response['user']['couple_id']);
      }

      if (response['user'] != null) {
        final user = response['user'];
        final userId = user['id'];
        if (userId != null) appProvider.setUserId(userId.toString());
        appProvider.setDisplayName(user['display_name'] ?? '');
        appProvider.setGender(user['gender'] ?? '');
      }

      if (appProvider.partnerId == null) {
        final partner = response['partner'];
        if (partner != null && mounted) {
          appProvider.connectPartner(
            partner['username'] ?? '',
            partnerId: partner['id']?.toString(),
            displayName: partner['display_name'],
            partnerGender: partner['gender'],
          );
          context.read<PeriodProvider>().loadPartnerData();
          _connectToSocket();
          _forceStopTimerIfConnected();
        }
      }
    } catch (_) {}
  }

  void _connectToSocket() {
    if (!mounted) return;
    final appProvider = context.read<AppProvider>();
    final token = ApiService.token;
    if (token == null || appProvider.userId == null) return;

    String roomId;
    if (appProvider.partnerId != null) {
      final ids = [appProvider.userId!, appProvider.partnerId!]..sort();
      roomId = 'couple_${ids[0]}_${ids[1]}';
    } else {
      roomId = 'cinema_${appProvider.userId}';
    }

    SocketService.connect(token: token, roomId: roomId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<MomentProvider>().loadMoments();
        });
      }
    });

    SocketService.onMessage = (data) {
      if (!mounted) return;
      if (data['action'] == 'incoming_invitation') _showInvitationDialog(data);
      if (data['action'] == 'reinvite') _showReinvitationDialog(data);
    };
  }

  void _showInvitationDialog(Map<String, dynamic> data) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => InvitationDialog(
        hostName: data['hostName'] ?? 'عزیزم',
        title: 'دعوت به سینما 🎬',
        message: 'تو رو به یه سینمای خصوصی دعوت کرده! 🍿',
        acceptText: 'آره، بیا بریم! 🍿',
        rejectText: 'نه، ممنون',
        onAccept: () {
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
          );
        },
        onReject: () {
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showReinvitationDialog(Map<String, dynamic> data) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => InvitationDialog(
        hostName: data['hostName'] ?? 'عزیزم',
        title: 'دعوت مجدد 🔄',
        message: 'دوباره دعوتت کرده به سینما!\nمنتظرته... 💕',
        acceptText: 'برمی‌گردم ❤️',
        rejectText: 'الان نه',
        onAccept: () {
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
          );
        },
        onReject: () {
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onConnected() {
    if (!mounted) return;
    context.read<AppProvider>().connectPartner('پارتنر');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('وصل شدین! 💕', style: TextStyle(fontFamily: 'Vazir')),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openCinemaRoom() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
    );
  }

  @override
  void dispose() {
    _stopSmartTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final appTheme = Theme.of(context).extension<AppTheme>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: ValueKey('home_${isDark ? 'dark' : 'light'}'),
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    appTheme?.surfaceBackground ?? const Color(0xFF121212),
                    appTheme?.cardBackground ?? const Color(0xFF1E1E1E)
                  ]
                : [const Color(0xFFFFFFFF), const Color(0xFFF7F7FF)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Header(onMenuTap: () => setState(() => _isMenuOpen = true)),
                  const SizedBox(height: 12),
                  const CalendarStrip(),
                  const SizedBox(height: 12),
                  if (!appProvider.isConnected && appProvider.partnerId == null)
                    ConnectBanner(onConnected: _onConnected),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Consumer<AppProvider>(
                      builder: (context, appProvider, _) {
                        if (appProvider.userId == null ||
                            appProvider.userId!.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          );
                        }

                        final hasPartner = appProvider.partnerId != null &&
                            appProvider.partnerId!.isNotEmpty;

                        if (!hasPartner) {
                          return LockedWidget(
                            child: BodyCards(
                              onMissYouPressed: () =>
                                  appProvider.incrementFeeling(),
                            ),
                            message: 'پارتنرت رو دعوت کن 💕',
                          );
                        }

                        return BodyCards(
                          onMissYouPressed: () =>
                              appProvider.incrementFeeling(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_isMenuOpen)
              SideMenu(onClose: () => setState(() => _isMenuOpen = false)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  buildBottomNav(context, activePage: 'home'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: const _CinemaFAB(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CinemaFAB extends StatelessWidget {
  const _CinemaFAB();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
        ),
        child:
            const Icon(Icons.play_arrow_rounded, size: 45, color: Colors.white),
      ),
    );
  }
}
