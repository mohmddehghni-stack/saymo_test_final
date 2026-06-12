import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:flutter_application_1/shared/widgets/user_avatar.dart';

class Header extends StatefulWidget {
  final VoidCallback onMenuTap;
  const Header({super.key, required this.onMenuTap});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  DateTime? startDate;
  bool isCounting = false;
  Duration elapsed = Duration.zero;
  Timer? _timer;

  static const Color primaryPink = Color(0xFFFE4773);
  // دقیقاً همون رنگ selectedCardBg از AddMomentSheet
  static const Color headerBg = Color.fromARGB(255, 255, 244, 244);

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (startDate != null) {
        setState(() => elapsed = DateTime.now().difference(startDate!));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: headerBg, // پس‌زمینه صورتی لطیف
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1A1A2E)),
            onPressed: widget.onMenuTap,
          ),
          const Spacer(),
          !isCounting ? _buildDatePicker() : _buildCounter(),
          const Spacer(),
          UserAvatar(
            username: appProvider.username ?? 'کاربر',
            gender: appProvider.gender ?? 'male',
            imageUrl: appProvider.avatarUrl,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('fa'),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryPink,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(fontFamily: 'Vazir'),
                  bodyMedium: TextStyle(fontFamily: 'Vazir'),
                  bodySmall: TextStyle(fontFamily: 'Vazir'),
                  titleLarge: TextStyle(fontFamily: 'Vazir'),
                  titleMedium: TextStyle(fontFamily: 'Vazir'),
                  titleSmall: TextStyle(fontFamily: 'Vazir'),
                  labelLarge: TextStyle(fontFamily: 'Vazir'),
                  labelMedium: TextStyle(fontFamily: 'Vazir'),
                  labelSmall: TextStyle(fontFamily: 'Vazir'),
                  headlineLarge: TextStyle(fontFamily: 'Vazir'),
                  headlineMedium: TextStyle(fontFamily: 'Vazir'),
                  headlineSmall: TextStyle(fontFamily: 'Vazir'),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            startDate = picked;
            isCounting = true;
            elapsed = DateTime.now().difference(picked);
          });
          _startTimer();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: primaryPink, size: 18),
            const SizedBox(width: 6),
            const Text('تاریخ شروع رابطه',
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Vazir',
                    color: Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter() {
    final years = (elapsed.inDays / 365.25).floor();
    final remainingDays = elapsed.inDays - (years * 365).toInt();
    final months = (remainingDays / 30.44).floor();
    final days = remainingDays - (months * 30).toInt();
    final hours = elapsed.inHours % 24;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPink.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: primaryPink, size: 14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$years سال  $months ماه  $days روز',
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Vazir',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E)),
              ),
              Text(
                '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}',
                style: const TextStyle(
                    fontSize: 10, fontFamily: 'Vazir', color: primaryPink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
