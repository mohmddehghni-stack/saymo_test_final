import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../../../core/theme/app_colors.dart';

class TabSwitcher extends StatelessWidget {
  final int currentTab;
  final Function(int) onTabChanged;

  const TabSwitcher({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tabItem(0, Icons.calendar_today, 'تقویم'),
            _tabDivider(),
            _tabItem(1, Icons.bloodtype, 'پریود'),
            _tabDivider(),
            _tabItem(2, Icons.edit_note, 'یادداشت'),
          ],
        ),
      ),
    );
  }

  Widget _tabDivider() {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _tabItem(int index, IconData icon, String label) {
    final isActive = currentTab == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                size: 22,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 12,
                  color: isActive ? Colors.white : Colors.transparent,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
