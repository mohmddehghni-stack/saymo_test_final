import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/calendar/pages/calendar_page.dart';
import '../../features/profile/pages/profile_page.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد
import 'package:flutter_application_1/shared/widgets/navigation_helper.dart';

Widget buildBottomNav(
  BuildContext context, {
  String activePage = 'home',
}) {
  if (activePage == 'notes') return const SizedBox.shrink();

  // 🔥 دریافت تم
  final appTheme = Theme.of(context).extension<AppTheme>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // رنگ‌های تطبیق‌یافته
  final Color navBg = isDark
      ? const Color.fromARGB(255, 43, 43, 43)
      : (appTheme?.cardBackground ?? Colors.white); // سفید در روز
  final Color inactiveColor = appTheme?.textHint ?? Colors.grey.shade500;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    child: Container(
      height: 68,
      decoration: BoxDecoration(
        color: navBg, // 👈 پس‌زمینه پویا
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ModernNavItem(
              icon: Icons.home_rounded,
              label: 'خانه',
              isActive: activePage == 'home',
              onTap: () {
                if (activePage != 'home') {
                  navigateTo(context, const HomePage());
                }
              },
              inactiveColor: inactiveColor, // 👈
            ),
            _ModernNavItem(
              icon: Icons.calendar_today_rounded,
              label: 'تقویم',
              isActive: activePage == 'calendar',
              onTap: () {
                if (activePage != 'calendar') {
                  navigateTo(context, const CalendarPage());
                }
              },
              inactiveColor: inactiveColor, // 👈
            ),
            _ModernNavItem(
              icon: Icons.movie_rounded,
              label: 'سینما',
              isActive: activePage == 'cinema',
              onTap: () {
                // مسیر سینما
              },
              inactiveColor: inactiveColor, // 👈
            ),
            _ModernNavItem(
              icon: Icons.person_rounded,
              label: 'پروفایل',
              isActive: activePage == 'profile',
              onTap: () {
                if (activePage != 'profile') {
                  navigateTo(context, const ProfilePage());
                }
              },
              inactiveColor: inactiveColor, // 👈
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================
// 🔥 آیتم مدرن با نشانگر بالا و انیمیشن مقیاس
// ============================================
class _ModernNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color inactiveColor; // 👈 جدید

  const _ModernNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.inactiveColor, // 👈
  });

  @override
  State<_ModernNavItem> createState() => _ModernNavItemState();
}

class _ModernNavItemState extends State<_ModernNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    if (widget.isActive) _animController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _ModernNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // نشانگر بالایی (Pill)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.isActive ? 24 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: widget.isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            // آیکون با مقیاس
            AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                );
              },
              child: Icon(
                widget.icon,
                size: 24,
                color: widget.isActive
                    ? AppColors.primary
                    : widget.inactiveColor, // 👈 جایگزین Colors.grey.shade500
              ),
            ),
            const SizedBox(height: 4),
            // متن
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Vazir',
                fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w400,
                color: widget.isActive
                    ? AppColors.primary
                    : widget.inactiveColor, // 👈
              ),
            ),
          ],
        ),
      ),
    );
  }
}
