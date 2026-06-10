import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/providers/moment_provider.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';
import 'package:flutter_application_1/shared/widgets/bottom_nav.dart';
import 'package:flutter_application_1/features/notes/pages/notes_tab.dart';
import 'package:flutter_application_1/features/period/pages/period_tab.dart';
import 'package:flutter_application_1/features/calendar/widgets/tab_switcher.dart';
import 'package:flutter_application_1/features/calendar/widgets/calendar_header.dart';
import 'package:flutter_application_1/features/calendar/widgets/calendar_content.dart';
import 'package:flutter_application_1/features/calendar/widgets/event_data.dart';
import '../widgets/speed_fan_fab.dart';
import '../sheets/add_moment_sheet.dart';
import '../sheets/add_note_sheet.dart';
import 'dart:ui';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:flutter_application_1/core/services/event_bus.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
import 'package:flutter_application_1/features/calendar/sheets/add_moment_sheet.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  int _currentTab = 0;

  late AnimationController _entranceAnim;
  late Animation<double> _fadeSlideAnimation;
  final GlobalKey<SpeedFanFABState> _fabKey = GlobalKey<SpeedFanFABState>();
  bool _showBlur = false;

  Timer? _eventTimer;
  int _currentEventIndex = 0;
  String _currentEventKey = 'event_0';

  static const Color primaryPink = AppColors.primary;
  static const Color softBg = AppColors.backgroundLight;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startEventTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToErrors();
      final mp = context.read<MomentProvider>();
      final pp = context.read<PeriodProvider>();
      final eventBus = context.read<EventBus>();

      // WebSocket
      SocketService.addHandler((data) {
        if (data['action'] == 'moment_updated') mp.loadMoments();
      });

      // EventBus
      eventBus.addListener(() {
        if (eventBus.lastEvent == 'moment_updated') mp.loadMoments();
      });

      // Listeners for UI rebuild
      pp.addListener(() {
        if (mounted) setState(() {});
      });
      mp.addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  void _listenToErrors() {
    final cp = context.read<CalendarProvider>();
    cp.addListener(() {
      if (cp.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(cp.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'باشه',
              textColor: Colors.white,
              onPressed: () => cp.clearError(),
            ),
          ),
        );
      }
    });
  }

  void _setupAnimations() {
    _entranceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeSlideAnimation = CurvedAnimation(
      parent: _entranceAnim,
      curve: Curves.easeOutCubic,
    );
    _entranceAnim.forward();
  }

  void _startEventTimer() {
    _eventTimer?.cancel();
    _eventTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final cp = context.read<CalendarProvider>();
      final events = _getAllEvents(cp);
      if (events.isEmpty) return;

      setState(() {
        _currentEventIndex = (_currentEventIndex + 1) % events.length;
        _currentEventKey =
            'event_${_currentEventIndex}_${DateTime.now().millisecondsSinceEpoch}';
      });
    });
  }

  @override
  void dispose() {
    _entranceAnim.dispose();
    _eventTimer?.cancel();
    super.dispose();
  }

  // =============================================
  // 🔥 گرفتن همه رویدادها
  // =============================================
  List<EventData> _getAllEvents(CalendarProvider cp) {
    final events = <EventData>[];
    final appProvider = context.read<AppProvider>();
    final isFemale = appProvider.gender == 'female';

    try {
      final pp = context.read<PeriodProvider>();
      final mp = context.read<MomentProvider>();

      // ۱. رویدادهای یادداشت‌ها (مشترک)
      cp.savedNotesWithFullKey.forEach((key, value) {
        try {
          final parts = key.split('-');
          if (parts.length != 3) return;

          final date = Jalali(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );

          if (date.month != cp.selectedMonth || date.year != cp.selectedYear)
            return;

          if (value.containsKey(cp.userId)) {
            events.add(EventData(
              icon: '📝',
              text: '${cp.formatDate(date.day)} - یادداشت تو',
              shortText: 'یادداشت ${cp.formatDate(date.day)}',
              color: primaryPink,
              date: date,
            ));
          }

          if (cp.partnerId != null && value.containsKey(cp.partnerId)) {
            final note = value[cp.partnerId]!;
            if (note['isPrivate'] != true) {
              events.add(EventData(
                icon: '💕',
                text: '${cp.formatDate(date.day)} - یادداشت پارتنر',
                shortText: 'پارتنر ${cp.formatDate(date.day)}',
                color: const Color(0xFF5B8DEF),
                date: date,
              ));
            }
          }
        } catch (e) {}
      });

      // ۲. رویدادهای پریود
      /*if (isFemale) {
        if (pp.lastPeriodStart != null) {
          final periodDates =
              pp.getPeriodDatesForMonth(cp.selectedMonth, cp.selectedYear);
          for (final date in periodDates) {
            events.add(EventData(
              icon: '🌸',
              text: '${cp.formatDate(date.day)} - روز پریود',
              shortText: 'پریود ${cp.formatDate(date.day)}',
              color: const Color(0xFFF5576C),
              date: date,
            ));
          }

          final predictedDates = pp.getPredictedPeriodDatesForMonth(
              cp.selectedMonth, cp.selectedYear);
          for (final date in predictedDates) {
            events.add(EventData(
              icon: '🔮',
              text: '${cp.formatDate(date.day)} - پیش‌بینی پریود',
              shortText: 'پیش‌بینی ${cp.formatDate(date.day)}',
              color: const Color(0xFFF5576C).withOpacity(0.5),
              date: date,
            ));
          }
        }
      } else {
        if (pp.isPartnerSetupDone) {
          final partnerDates = pp.getPartnerPeriodDatesForMonth(
              cp.selectedMonth, cp.selectedYear);
          for (final date in partnerDates) {
            events.add(EventData(
              icon: '🌸',
              text: '${cp.formatDate(date.day)} - پریود پارتنر',
              shortText: 'پریود ${cp.formatDate(date.day)}',
              color: const Color(0xFFF5576C),
              date: date,
            ));
          }

          final partnerPredicted = pp.getPartnerPredictedPeriodDatesForMonth(
              cp.selectedMonth, cp.selectedYear);
          for (final date in partnerPredicted) {
            events.add(EventData(
              icon: '🔮',
              text: '${cp.formatDate(date.day)} - پیش‌بینی',
              shortText: 'پیش‌بینی ${cp.formatDate(date.day)}',
              color: const Color(0xFFF5576C).withOpacity(0.5),
              date: date,
            ));
          }
        }
      }*/

      // ۳. لحظه‌ها
      for (final moment in mp.moments) {
        if (moment.isPrivate && moment.userId != cp.userId) continue;
        events.add(EventData(
          icon: moment.emoji,
          text: mp.countdownText(moment),
          shortText: moment.title,
          color: moment.category == 'milestone'
              ? Colors.amber.shade600
              : moment.category == 'first'
                  ? Colors.deepOrange.shade300
                  : primaryPink,
          date: moment.date,
        ));
      }
    } catch (e) {
      debugPrint('Error in _getAllEvents: $e');
    }

    events.sort((a, b) => a.date.toDateTime().compareTo(b.date.toDateTime()));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalendarProvider>();
    context.watch<MomentProvider>();
    context.watch<PeriodProvider>();

    final allEvents = _getAllEvents(cp);
    final currentEvent =
        allEvents.isNotEmpty && _currentEventIndex < allEvents.length
            ? allEvents[_currentEventIndex]
            : null;

    return Scaffold(
      extendBody: true, // 👈 این خط رو اضافه کن
      backgroundColor: softBg,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeSlideAnimation,
            child: Column(
              children: [
                if (_currentTab == 0)
                  CalendarHeader(
                    currentEvent: currentEvent,
                    allEvents: allEvents,
                    currentEventIndex: _currentEventIndex,
                    currentEventKey: _currentEventKey,
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      const CalendarContent(),
                      Builder(
                        builder: (context) {
                          final appProvider = context.watch<AppProvider>();
                          return PeriodTab(
                            key: ValueKey('period_${appProvider.userId}'),
                            isFemale: appProvider.gender == 'female',
                          );
                        },
                      ),
                      const NotesTabContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 6,
            left: 16,
            right: 16,
            child: TabSwitcher(
              currentTab: _currentTab,
              onTabChanged: (i) {
                setState(() => _currentTab = i);
                HapticFeedback.lightImpact();
              },
            ),
          ),
          if (_showBlur)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _fabKey.currentState?.close(),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _showBlur ? 1.0 : 0.0,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: buildBottomNav(context,
                activePage: _currentTab == 2 ? 'notes' : 'calendar'),
          ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? Padding(
              padding:
                  const EdgeInsets.only(bottom: 80), // 🔥 ۸۰px فاصله از پایین
              child: _buildSpeedFanFAB(),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSpeedFanFAB() {
    return SpeedFanFAB(
      key: _fabKey,
      fabColor: const Color(0xFFE8456B),
      fabSize: 60,
      itemSize: 40,
      radius: 90,
      closeIcon: Icons.add_rounded,
      openIcon: Icons.close_rounded,
      onOpenChanged: () {
        if (mounted) {
          setState(() {
            _showBlur = _fabKey.currentState?.isOpen ?? false;
          });
        }
      },
      items: [
        FanItem(
          label: 'خاطره',
          icon: Icons.bookmark_rounded,
          color: const Color(0xFF9B59B6),
          onTap: () {
            final cp = context.read<CalendarProvider>();
            AddNoteSheet.show(context, cp);
            _fabKey.currentState?.close();
          },
        ),
        FanItem(
          label: 'لحظه',
          icon: Icons.event_rounded,
          color: const Color(0xFFFFB347),
          onTap: () {
            final momentProvider = context.read<MomentProvider>();
            AddMomentSheet.show(context, momentProvider);
            _fabKey.currentState?.close();
          },
        ),
        FanItem(
          label: 'یادداشت',
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF5B8DEF),
          onTap: () {
            final cp = context.read<CalendarProvider>();
            AddNoteSheet.show(context, cp);
            _fabKey.currentState?.close();
          },
        ),
      ],
    );
  }
}

class _MalePeriodPlaceholder extends StatelessWidget {
  const _MalePeriodPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👨‍🦰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'اطلاعات سیکل پارتنر شما اینجا نمایش داده می‌شود',
            style: TextStyle(
                fontFamily: 'Vazir', fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'این بخش مخصوص پارتنر شماست 👩‍🦰',
            style: TextStyle(
                fontFamily: 'Vazir', fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
