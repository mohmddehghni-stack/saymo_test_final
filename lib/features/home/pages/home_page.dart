import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/side_menu.dart';
import '../../../shared/services/socket_service.dart';
import '../../video/pages/cinema_room_page.dart'; // 👈 جدید
import '../../video/services/cinema_room_service.dart'; // 👈 جدید
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
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/widgets/locked_widget.dart';
import '../widgets/body_cards.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';

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

    // ۱. اگه پارتنر از قبل توی SharedPreferences بوده، فوراً داده‌هاش رو بگیر
    if (appProvider.partnerId != null && appProvider.partnerId!.isNotEmpty) {
      context.read<PeriodProvider>().loadPartnerData();
    }

    // ۲. فقط یک Listener برای همه‌ی تغییرات
    appProvider.addListener(() {
      if (appProvider.partnerId != null && appProvider.partnerId!.isNotEmpty) {
        context.read<PeriodProvider>().loadPartnerData();
        _connectToSocket(); // سوکت رو به اتاق couple_ تغییر بده
        _stopSmartTimer(); // تایمر دیگه لازم نیست
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
      // 🔥 وقتی برنامه دوباره باز شد، لحظه‌ها رو به‌روز کن
      context.read<MomentProvider>().loadMoments();
    } else if (state == AppLifecycleState.paused) {
      _isAppInForeground = false;
      _stopSmartTimer();
    }
  }

  void _startSmartTimer() {
    _stopSmartTimer();
    _partnerCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_isAppInForeground) {
        _stopSmartTimer();
        return;
      }
      final appProvider = context.read<AppProvider>();
      // 🔥 اگر coupleId داریم و پارتنر هم داریم، دیگه نیازی به تایمر نیست
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
    final appProvider = context.read<AppProvider>();
    if (appProvider.partnerId != null) {
      _stopSmartTimer();
    }
  }

  Future<void> _tryPullPartner() async {
    final appProvider = context.read<AppProvider>();
    if (appProvider.userId == null) return;

    try {
      final response = await ApiService.getProfile();

      // ذخیره coupleId
      if (response['user']?['couple_id'] != null) {
        appProvider.setCoupleId(response['user']['couple_id']);
      }

      // ذخیره اطلاعات خود کاربر
      if (response['user'] != null) {
        final user = response['user'];
        final userId = user['id'];
        if (userId != null) appProvider.setUserId(userId.toString());
        appProvider.setDisplayName(user['display_name'] ?? '');
        appProvider.setGender(user['gender'] ?? '');
      }

      // اگر پارتنر وصل نشده بود و حالا وصل شد
      if (appProvider.partnerId == null) {
        final partner = response['partner'];
        if (partner != null) {
          appProvider.connectPartner(
            partner['username'] ?? '',
            partnerId: partner['id']?.toString(),
            displayName: partner['display_name'],
            partnerGender: partner['gender'],
          );
          context.read<PeriodProvider>().loadPartnerData();
          // 🔥 این دو خط را اضافه کن:
          _connectToSocket(); // اتاق را به couple_ تغییر بده
          _forceStopTimerIfConnected();
        }
      }
    } catch (_) {}
  }

  void _connectToSocket() {
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

    SocketService.onMessage = (data) {
      if (data['action'] == 'incoming_invitation') _showInvitationDialog(data);
      if (data['action'] == 'reinvite') _showReinvitationDialog(data);
    };
  }

  // برای دعوت معمولی
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
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
          );
        },
        onReject: () => Navigator.pop(context),
      ),
    );
  }

// برای دعوت مجدد
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
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
          );
        },
        onReject: () => Navigator.pop(context),
      ),
    );
  }

  void _onConnected() {
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

  // 👈 ورود به سینمای دونفره
  void _openCinemaRoom() {
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
    print(
        '🏠 DEBUG HomePage -> coupleId: ${ApiService.coupleId}, token: ${ApiService.token != null ? "YES" : "NO"}');

    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 247, 247, 255)
              ]),
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
                        // 🔥 اگه userId هنوز لود نشده، Loading نشون بده
                        if (appProvider.userId == null ||
                            appProvider.userId!.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          );
                        }

                        // 🔥 اگه userId هست ولی partnerId نیست، قفل کن
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
              child: buildBottomNav(context, activePage: 'home'),
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
