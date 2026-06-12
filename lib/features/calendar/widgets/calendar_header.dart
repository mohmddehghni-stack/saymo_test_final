import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:flutter_application_1/shared/widgets/user_avatar.dart';
import 'event_banner.dart';
import 'event_data.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class CalendarHeader extends StatelessWidget {
  final EventData? currentEvent;
  final List<EventData> allEvents;
  final int currentEventIndex;
  final String currentEventKey;

  const CalendarHeader({
    super.key,
    this.currentEvent,
    this.allEvents = const [],
    this.currentEventIndex = 0,
    this.currentEventKey = 'event_0',
  });

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalendarProvider>();
    final appProvider = context.watch<AppProvider>();

    // 🔥 گرفتن تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final EventData? displayEvent;
    if (currentEvent != null) {
      displayEvent = currentEvent;
    } else if (allEvents.isNotEmpty) {
      displayEvent = allEvents.first;
    } else {
      displayEvent = null;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  appTheme?.surfaceBackground ?? const Color(0xFF121212),
                  appTheme?.cardBackground ?? const Color(0xFF1E1E1E),
                  const Color(0xFF2A0A2E), // یه ته‌رنگ بنفش تیره
                ]
              : [
                  const Color(0xFFE8456B),
                  AppColors.primary,
                  const Color(0xFFFF8E9E),
                ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 50,
          bottom: 20,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDateDisplay(cp)),
                _buildAvatars(cp, appProvider),
              ],
            ),
            const SizedBox(height: 14),
            if (displayEvent != null)
              EventBanner(
                currentEvent: displayEvent,
                allEvents: allEvents,
                currentIndex: currentEventIndex,
                eventKey: currentEventKey,
              )
            else
              _buildEmptyBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white70, size: 18),
          SizedBox(width: 10),
          Text('یه لحظه قشنگ ثبت کن ✨',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12, fontFamily: 'Vazir')),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(CalendarProvider cp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(cp.weekDayName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Vazir', color: Colors.white),
            children: [
              TextSpan(
                text: '${cp.selectedDay ?? cp.todayDay ?? 1}',
                style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1),
              ),
              TextSpan(
                  text: ' ${cp.monthName}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatars(CalendarProvider cp, AppProvider appProvider) {
    final isOnline = appProvider.isConnected;
    const double avatarSize = 50;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // آواتارها
        SizedBox(
          width: 70,
          height: 46,
          child: Stack(
            children: [
              // 🔥 خودم (راست - تراز وسط)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: UserAvatar(
                    username: appProvider.username ?? 'کاربر',
                    gender: appProvider.gender ?? 'male',
                    imageUrl: appProvider.avatarUrl,
                    size: 36, // کمی کوچک‌تر
                  ),
                ),
              ),
              // 🔥 پارتنر (چپ - تراز وسط - اورلب)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    username: appProvider.partnerUsername ?? 'پارتنر',
                    gender: appProvider.gender == 'male' ? 'female' : 'male',
                    imageUrl: appProvider.partnerAvatarUrl,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // 🔥 وضعیت آنلاین - وسط چین
        SizedBox(
          width: 70, // هم عرض آواتارها
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFFBBF24),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isOnline ? 'متصل' : 'آفلاین',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
