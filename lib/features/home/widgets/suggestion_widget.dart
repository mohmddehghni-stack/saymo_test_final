import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';
import 'package:flutter_application_1/core/providers/couple_cache_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class SuggestionWidget extends StatefulWidget {
  const SuggestionWidget({super.key});

  @override
  State<SuggestionWidget> createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget>
    with SingleTickerProviderStateMixin {
  final Map<String, List<String>> _smartSuggestions = {
    'period': [
      'حواس‌ت بهش باشه، شکلات بخر 🍫',
      'براش نوشیدنی گرم درست کن ☕',
      'بهش بگو "استراحت کن، من هستم" 🌸',
      'براش فیلم مورد علاقه‌اش رو بذار 🎥',
    ],
    'follicular': [
      'پر انرژیه، بهش پیشنهاد ماجراجویی بده 🗺️',
      'بهش بگو "می‌خوام ببینمت" 😍',
      'امروز روز خوبی برای سورپرایزه 🎁',
    ],
    'ovulation': [
      'اوج انرژی و جذابیتشه! 😍',
      'بهترین وقت برای قرار عاشقونه 💕',
      'بهش بگو چقدر خوشگله ✨',
    ],
    'luteal': [
      'یه کم حساس‌تره، مراقبش باش 🌙',
      'براش یه پیام محبت‌آمیز بفرست 🤗',
      'شکلات تلخ و غذای خونگی 🍫',
    ],
    'pms': [
      'صبور باش، روزای سختیه 🌧️',
      'بهش فضا بده، یه کم صبر کن 🌸',
      'یه فیلم خوب و پتوی نرم 🎬',
    ],
    'default': [
      'بهش بگو چقدر دلت براش تنگ شده 💕',
      'امروز بهش بگو چقدر خوشگله 😍',
      'یه پیام صبح بخیر عاشقانه بفرست ☀️',
      'یه آهنگ عاشقانه براش بفرست 🎵',
    ],
  };

  late String _currentSuggestion;
  late final AnimationController _pulseController;
  String _currentPhase = 'default';

  @override
  void initState() {
    super.initState();
    _updateSuggestion();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _updateSuggestion() {
    final suggestions =
        _smartSuggestions[_currentPhase] ?? _smartSuggestions['default']!;
    _currentSuggestion = (suggestions..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 گرفتن تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pp = context.watch<PeriodProvider>();
    final cache = context.watch<CoupleCacheProvider>();

    String newPhase = 'default';
    if (pp.isSetupDone) {
      final phase = pp.currentPhase;
      if (phase == 'قاعدگی') {
        newPhase = 'period';
      } else if (phase == 'فولیکولار') {
        newPhase = 'follicular';
      } else if (phase == 'تخمک‌گذاری') {
        newPhase = 'ovulation';
      } else if (phase == 'لوتئال اولیه') {
        newPhase = 'luteal';
      } else if (phase == 'PMS') {
        newPhase = 'pms';
      }
    }

    if (cache.partnerFeeling.isNotEmpty) {
      if (cache.partnerFeeling.contains('ناراحت')) {
        newPhase = 'pms';
      } else if (cache.partnerFeeling.contains('خوشحال') ||
          cache.partnerFeeling.contains('انرژی')) {
        newPhase = 'follicular';
      } else if (cache.partnerFeeling.contains('عصبانی')) {
        newPhase = 'luteal';
      } else if (cache.partnerFeeling.contains('گرسنه')) {
        newPhase = 'default';
      }
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      _updateSuggestion();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // پس‌زمینه: در تم روشن صورتی خیلی کمرنگ، در تم تاریک سطح کارت
        color: isDark
            ? (appTheme?.cardBackground ?? const Color(0xFF1E1E1E))
            : AppColors.primary.withOpacity(0.06),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary
                      .withOpacity(0.1 + _pulseController.value * 0.1),
                ),
                child: const Text('💡', style: TextStyle(fontSize: 18)),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentSuggestion,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Vazir',
                // متن: در تم روشن تیره، در تم تاریک روشن
                color: appTheme?.textPrimary ?? AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
