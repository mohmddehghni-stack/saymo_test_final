import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/calendar/pages/calendar_page.dart';
import '../../features/profile/pages/profile_page.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: isActive ? activeColor : Colors.black54),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Vazir',
              color: isActive ? activeColor : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildBottomNav(
  BuildContext context, {
  String activePage = 'home',
  bool fabInCenter = true,
}) {
  return BottomAppBar(
    shape: fabInCenter ? const CircularNotchedRectangle() : null,
    notchMargin: fabInCenter ? 14 : 0,
    elevation: 12,
    color: Colors.white,
    child: SizedBox(
      height: 74,
      child: fabInCenter
          ? Row(
              // 👈 حالت FAB وسط (همون نسخه اصلی)
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNavItem(
                  icon: Icons.home_filled,
                  label: 'خانه',
                  isActive: activePage == 'home',
                  onTap: () {
                    if (activePage != 'home') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    }
                  },
                ),
                BottomNavItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'تقویم',
                  isActive: activePage == 'calendar',
                  onTap: () {
                    if (activePage != 'calendar') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarPage()),
                      );
                    }
                  },
                ),
                const SizedBox(width: 64),
                BottomNavItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'چالش‌ها',
                  isActive: activePage == 'challenges',
                  onTap: () {},
                ),
                BottomNavItem(
                  icon: Icons.person_outline,
                  label: 'پروفایل',
                  isActive: activePage == 'profile',
                  onTap: () {
                    if (activePage != 'profile') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                ),
              ],
            )
          : Row(
              // 👈 حالت FAB شناور (فقط توی تقویم)
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNavItem(
                  icon: Icons.home_filled,
                  label: 'خانه',
                  isActive: activePage == 'home',
                  onTap: () {
                    if (activePage != 'home') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    }
                  },
                ),
                BottomNavItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'تقویم',
                  isActive: activePage == 'calendar',
                  onTap: () {
                    if (activePage != 'calendar') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarPage()),
                      );
                    }
                  },
                ),
                BottomNavItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'چالش‌ها',
                  isActive: activePage == 'challenges',
                  onTap: () {},
                ),
                BottomNavItem(
                  icon: Icons.person_outline,
                  label: 'پروفایل',
                  isActive: activePage == 'profile',
                  onTap: () {
                    if (activePage != 'profile') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                ),
              ],
            ),
    ),
  );
}
