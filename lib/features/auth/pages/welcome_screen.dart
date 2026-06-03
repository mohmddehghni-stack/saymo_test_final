import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/features/auth/pages/login_page.dart';
import 'package:flutter_application_1/features/auth/pages/register_new_page.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: SizedBox(
        height: screenHeight - topPadding - bottomPadding,
        child: Stack(
          children: [
            // ===== لایه ۱: تصویر + المان‌های تزئینی =====
            Align(
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  // تصویر اصلی
                  Image.asset(
                    'assets/images/couple.png',
                    width: screenWidth,
                    fit: BoxFit.contain,
                  ),

                  // المان‌های شناور (قلب‌های کوچک)
                  ...List.generate(6, (i) {
                    final random = (i * 137) % 100 / 100;
                    return Positioned(
                      top: screenHeight * 0.08 + (i * 40),
                      left: screenWidth * (0.1 + random * 0.7),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 2000 + (i * 300)),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: (value * 0.6).clamp(0.0, 0.6),
                            child: Transform.translate(
                              offset: Offset(0, -20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.primary.withOpacity(0.3),
                          size: 12.0 + (i * 3),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ===== لایه ۲: محتوای متنی (انیمیشن دار) =====
            Positioned(
              top: screenHeight * 0.58,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // 👈 بچین از راست
                      children: [
                        // لوگو
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 8,
                          ),
                          child: const Text(
                            'Saymo ',
                            textAlign: TextAlign.right, // 👈 راست‌چین
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Vazir',
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // شعار اصلی
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'یه جای امن برای رابطه‌تون',
                            textAlign: TextAlign.right, // 👈 راست‌چین
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Vazir',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2723),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // متن توضیحی
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'حواستون به هم باشه،حتی از راه دور ❤️',
                            textAlign: TextAlign.right, // 👈 راست‌چین
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Vazir',
                              color: Color.fromARGB(150, 61, 61, 61),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== لایه ۴: دکمه‌ها =====
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    // دکمه ورود - اصلی
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'وارد شو',
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // دکمه ثبت نام - فرعی
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'جدیدی؟ با هم شروع کنیم',
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.favorite_border, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
