import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'wave_painter.dart';
import 'animated_wave_painter.dart';
import 'package:flutter_application_1/features/auth/pages/login_page.dart';
import 'package:flutter_application_1/features/auth/pages/register_new_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _waveController;
  late AnimationController _iconsController;
  late AnimationController _floatController;
  late AnimationController _buttonsController;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;
  late List<Animation<double>> _iconAnimations;

  final int _iconCount = 5;

  // اعداد مستقیم (هر وقت خواستی تغییر بده)
  static const double logoSize = 250;
  static const double circleRadius = 170;
  static const double iconSize = 40;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _iconsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _iconAnimations = List.generate(_iconCount, (index) {
      return CurvedAnimation(
        parent: _iconsController,
        curve: Interval(
          index * 0.12,
          1.0,
          curve: Curves.easeOutBack,
        ),
      );
    });

    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonsFade = CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOut,
    );

    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonsController,
        curve: Curves.easeOutCubic,
      ),
    );

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _iconsController.forward();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) _floatController.repeat();
      });
    });

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _buttonsController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _waveController.dispose();
    _iconsController.dispose();
    _floatController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final double circleDiameter = circleRadius * 2;
    final double stackHeight = 350 + circleDiameter;
    final double circleCenterY = stackHeight / 2;
    final double textTopOffset = circleCenterY + logoSize / 2 + 20;

    final List<double> iconAngles = List.generate(_iconCount, (index) {
      return -math.pi / 2 + (2 * math.pi / _iconCount) * index;
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.4, 1.0), // یکم مایل‌تر
            colors: [
              Color.fromARGB(255, 255, 68, 115), // صورتی بالا
              Color(0xffD96BB0), // بنفش متوسط وسط (مثال)
              Color.fromARGB(255, 166, 97, 255),
            ],
          ),
        ),
        child: Stack(
          children: [
            /// امواج پایین
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 260,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AnimatedWavePainter(_waveController.value),
                    );
                  },
                ),
              ),
            ),

            /// بخش لوگو + دایره + آیکن‌ها
            Positioned(
              top: screenHeight * 0.0,
              left: 0,
              right: 0,
              height: stackHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // دایره نازک
                  Container(
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // لوگو و متن‌ها
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: .85, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: stackHeight,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/images/saymo_logo.png",
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: textTopOffset,
                              left: 0,
                              right: 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "SAYMO",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight:
                                          FontWeight.w100, // نازک‌ترین حالت
                                      letterSpacing: 6, // فاصلهٔ بیشتر بین حروف
                                      shadows: [
                                        Shadow(
                                          color: Color(
                                              0x40FF6FAE), // سایهٔ صورتی خیلی کمرنگ
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "دو زندگی ، یک ریتم",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // آیکن‌های با حرکت حبابی
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: List.generate(_iconCount, (index) {
                          final angle = iconAngles[index];
                          final extraRadius = math.sin(
                                _floatController.value * 2 * math.pi +
                                    index * 0.8,
                              ) *
                              3;
                          final currentRadius = circleRadius + extraRadius;
                          final dx = currentRadius * math.cos(angle);
                          final dy = currentRadius * math.sin(angle);
                          final animation = _iconAnimations[index];

                          return Opacity(
                            opacity: animation.value,
                            child: Transform.translate(
                              offset: Offset(
                                  dx * animation.value, dy * animation.value),
                              child: _buildFeatureIcon(index, iconSize),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// دکمه‌ها
            Positioned(
              bottom: 120,
              left: 32,
              right: 32,
              child: FadeTransition(
                opacity: _buttonsFade,
                child: SlideTransition(
                  position: _buttonsSlide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              _createRoute(const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xffFF6FAE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black26,
                          ),
                          child: const Text(
                            'ورود',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              _createRoute(const RegisterNewPage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.7),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'ثبت‌نام',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(int index, double size) {
    const icons = [
      Icons.calendar_today,
      Icons.edit_note,
      Icons.play_arrow_rounded,
      Icons.whatshot,
      Icons.bloodtype,
    ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // gradient برداشته شد → دایره کاملاً شفاف
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255)
                .withOpacity(0.3), // سایه سفید
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Icon(
        icons[index],
        color: Colors.white,
        size: size * 0.47,
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
