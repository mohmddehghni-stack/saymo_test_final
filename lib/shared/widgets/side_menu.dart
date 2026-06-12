import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import '../../features/profile/pages/profile_page.dart';
import '../pages/support_page.dart';
import 'package:flutter_application_1/shared/widgets/user_avatar.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class SideMenu extends StatefulWidget {
  final VoidCallback onClose;
  const SideMenu({super.key, required this.onClose});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<double>(begin: 280, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _closeWithAnimation() {
    _animController.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color menuBgColor =
        appTheme?.cardBackground ?? AppColors.surfacePrimary;
    final Color textColor = appTheme?.textPrimary ?? AppColors.textPrimary;
    final Color hintColor = appTheme?.textHint ?? const Color(0xFF8E8E98);
    final Color dividerColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final Color iconColor =
        AppColors.primaryDark.withOpacity(isDark ? 0.9 : 0.7);
    final Color closeButtonBg = isDark ? Colors.white10 : Colors.grey.shade100;
    final Color closeIconColor = isDark ? Colors.white70 : Colors.grey;
    final Color logoutBg = Colors.red.withOpacity(isDark ? 0.1 : 0.06);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Stack(
          children: [
            // پس‌زمینه
            GestureDetector(
              onTap: _closeWithAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.35 * _fadeAnim.value),
              ),
            ),

            // منو
            Align(
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: Offset(_slideAnim.value, 0),
                child: Container(
                  width: 290,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: menuBgColor, // 👈 پس‌زمینه پویا
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      bottomLeft: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(-15, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // ─── پروفایل ───
                        _buildProfile(app,
                            textColor: textColor,
                            closeButtonBg: closeButtonBg,
                            closeIconColor: closeIconColor),

                        const SizedBox(height: 4),

                        // 🔥 خط جداکننده با گرادیانت
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withOpacity(0.2),
                                  AppColors.primary.withOpacity(0.4),
                                  AppColors.primary.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 28),
                            color: dividerColor), // 👈

                        const SizedBox(height: 16),

                        // ─── منو آیتم‌ها ───
                        _MenuItem(
                            icon: Icons.home_rounded,
                            title: 'خانه',
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () => _closeWithAnimation()),
                        _MenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'پروفایل',
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () {
                              _closeWithAnimation();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProfilePage()));
                            }),
                        _MenuItem(
                            icon: Icons.settings_outlined,
                            title: 'تنظیمات',
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () {
                              _closeWithAnimation();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProfilePage()));
                            }),
                        _MenuItem(
                            icon: Icons.headset_mic_outlined,
                            title: 'پشتیبانی',
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () {
                              _closeWithAnimation();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SupportPage()));
                            }),
                        _MenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'درباره ما',
                            iconColor: iconColor,
                            textColor: textColor,
                            onTap: () {
                              _closeWithAnimation();
                              _showAbout(context,
                                  appTheme: appTheme, isDark: isDark);
                            }),

                        const Spacer(),

                        // 🔥 خط جداکننده
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Container(
                            height: 1,
                            color: dividerColor, // 👈
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ─── خروج ───
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: GestureDetector(
                            onTap: () {
                              _closeWithAnimation();
                              app.logout();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/welcome', (route) => false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: logoutBg, // 👈
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded,
                                      color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('خروج',
                                      style: TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 14,
                                          color: Colors.red)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── پروفایل مینیمال ───
  Widget _buildProfile(
    AppProvider app, {
    required Color textColor,
    required Color closeButtonBg,
    required Color closeIconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        children: [
          UserAvatar(
            username: app.username ?? 'کاربر',
            gender: app.gender ?? 'male',
            imageUrl: app.avatarUrl,
            size: 56,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              app.displayName ?? app.username ?? 'کاربر',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor, // 👈
              ),
            ),
          ),
          GestureDetector(
            onTap: _closeWithAnimation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: closeButtonBg, // 👈
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.close_rounded,
                  color: closeIconColor, size: 18), // 👈
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context,
      {required AppTheme? appTheme, required bool isDark}) {
    final Color cardBg = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? Colors.black;
    final Color hintColor = appTheme?.textHint ?? Colors.black54;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: cardBg, // 👈
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌸', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('سایمو',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor)), // 👈
              const SizedBox(height: 8),
              Text('اپلیکیشن رابطه عاشقانه\nورژن ۱.۰.۰',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      color: hintColor)), // 👈
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('باشه 😊',
                    style: TextStyle(fontFamily: 'Vazir', color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── آیتم منو مینیمال ───
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor; // 👈 جدید
  final Color textColor; // 👈 جدید

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.iconColor, // 👈
    required this.textColor, // 👈
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22), // 👈
                const SizedBox(width: 14),
                Text(title,
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        color: textColor)), // 👈
              ],
            ),
          ),
        ),
      ),
    );
  }
}
