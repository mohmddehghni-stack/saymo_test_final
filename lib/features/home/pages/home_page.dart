import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/side_menu.dart';
import '../../../shared/services/socket_service.dart';
import '../../video/pages/video_lobby_page.dart';
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
    _connectToSocket();
    _tryPullPartner();
    _startSmartTimer(); // ← به جای تایمر ساده
  }

  Widget _buildHomeBody(AppProvider appProvider) {
    final body = BodyCards(
      onMissYouPressed: () => appProvider.incrementFeeling(),
    );

    if (!appProvider.isConnected) {
      return LockedWidget(
        child: body,
        message: 'پارتنرت رو دعوت کن 💕',
      );
    }

    return body;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      _tryPullPartner(); // چک فوری
      _startSmartTimer(); // دوباره استارت کن
    } else if (state == AppLifecycleState.paused) {
      _isAppInForeground = false;
      _stopSmartTimer(); // رفتیم تو بک‌گراند، تایمر بخواب
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
      if (appProvider.partnerId != null) {
        _stopSmartTimer(); // پارتنر اومد، تایمر خودکشی کن
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
    if (appProvider.userId != null && appProvider.partnerId == null) {
      try {
        final response = await ApiService.getProfile();
        final partner = response['partner'];
        if (partner != null) {
          appProvider.connectPartner(
            partner['username'] ?? '',
            partnerId: partner['id']?.toString(),
            displayName: partner['display_name'],
            partnerGender: partner['gender'],
          );
          _forceStopTimerIfConnected();
        }
      } catch (_) {}
    }
  }

  void _connectToSocket() {
    final appProvider = context.read<AppProvider>();
    if (appProvider.userId != null) {
      SocketService.connect(userId: appProvider.userId!, roomId: 'home');
      SocketService.onMessage = (data) {
        if (data['action'] == 'incoming_invitation') {
          _showInvitationDialog(data);
        }
        // 👈 جدید: گوش دادن به دعوت مجدد
        if (data['action'] == 'reinvite') {
          _showReinvitationDialog(data);
        }
      };
    }
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
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
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
                  if (!appProvider.isConnected)
                    ConnectBanner(onConnected: _onConnected),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildHomeBody(appProvider),
                  ),
                ],
              ),
            ),
            if (_isMenuOpen)
              SideMenu(onClose: () => setState(() => _isMenuOpen = false)),
          ],
        ),
      ),
      // 👈 دکمه شناور سینما (همیشه نمایش داده میشه)
      floatingActionButton: const _CinemaFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: buildBottomNav(context, activePage: 'home'),
    );
  }
}

class _CinemaFAB extends StatelessWidget {
  const _CinemaFAB();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
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
