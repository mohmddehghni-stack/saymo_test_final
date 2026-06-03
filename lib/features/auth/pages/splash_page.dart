import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter_application_1/core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  final Widget nextPage;
  const SplashPage({super.key, required this.nextPage});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _heartBeatController;
  late AnimationController _textSwitchController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _hintAnimation;
  late Animation<double> _heartBeatAnimation;

  bool _isNavigating = false;

  // فقط ۳ تا متن
  final List<String> _phrases = [
    'یه خونه برای دوتاتون 🏠',
    'هر روز یه خاطره جدید 💕',
    'جای گرم دلتنگی‌هاتون 💝',
  ];

  int _currentPhrase = 0;

  @override
  void initState() {
    super.initState();

    // کنترلر اصلی
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // پالس لوگو
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // حرکت ذرات
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // قلب تپنده (بعد ۲ ثانیه)
    _heartBeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _heartBeatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartBeatController, curve: Curves.easeOut),
    );

    // تعویض متن (هر ۳ ثانیه - کندتر)
    _textSwitchController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _textSwitchController.addListener(() {
      final newIndex = (_textSwitchController.value * _phrases.length).floor();
      if (newIndex != _currentPhrase && newIndex < _phrases.length) {
        setState(() {
          _currentPhrase = newIndex;
        });
      }
    });

    // انیمیشن‌های اصلی
    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _hintAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    // شروع انیمیشن‌ها
    _mainController.forward();

    // قلب تپنده بعد ۲ ثانیه
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _heartBeatController.forward();
      }
    });

    // متن اول ۲ ثانیه بمونه، بعد شروع به عوض شدن کنه
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _textSwitchController.repeat();
      }
    });

    // انتقال به صفحه بعد (۵ ثانیه - فرصت خوندن متن‌ها)
    Future.delayed(const Duration(milliseconds: 5000), () {
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextPage,
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _heartBeatController.dispose();
    _textSwitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: Colors.white, end: const Color(0xFFFFF5F5)),
      duration: const Duration(seconds: 2),
      builder: (context, color, child) {
        return Scaffold(
          backgroundColor: color,
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -100) {
                _navigateToNext();
              }
            },
            onTap: () => _navigateToNext(),
            child: Stack(
              children: [
                // ⭐ ذرات ساده و خفن (نسخه اصلی خودمون)
                ...List.generate(12, (i) {
                  return AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final dx = math.sin(_floatController.value * 2 + i) * 30;
                      final dy =
                          math.cos(_floatController.value * 1.5 + i) * 20;
                      return Positioned(
                        top: 100 + (i * 60) % 500,
                        left: 40 + (i * 80) % 300,
                        child: Transform.translate(
                          offset: Offset(dx, dy),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFE87984,
                        ).withOpacity(0.1 + (i * 0.03)),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),

                // 💓 قلب تپنده وسط صفحه
                AnimatedBuilder(
                  animation: _heartBeatAnimation,
                  builder: (context, child) {
                    if (_heartBeatAnimation.value <= 0) {
                      return const SizedBox.shrink();
                    }
                    return Positioned.fill(
                      child: Opacity(
                        opacity:
                            (1 - _heartBeatAnimation.value).clamp(0.0, 1.0) *
                                0.3,
                        child: Transform.scale(
                          scale: 0.5 + (_heartBeatAnimation.value * 2),
                          child: Center(
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.primary.withOpacity(
                                (1 - _heartBeatAnimation.value) * 0.3,
                              ),
                              size: 250,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // محتوای اصلی
                Center(
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Spacer(flex: 3),

                          // 🌸 لوگو با پالس
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.03),
                                child: child,
                              );
                            },
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE87984,
                                        ).withOpacity(0.15),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFFE87984,
                                        ).withOpacity(0.05),
                                        blurRadius: 80,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: CustomPaint(
                                      size: const Size(150, 150),
                                      painter: _SplashLogoPainter(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 📝 متن با سایه و انیمیشن تعویض
                          Opacity(
                            opacity: _opacityAnimation.value,
                            child: Column(
                              children: [
                                const Text(
                                  'سایمو',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontFamily: 'Vazir',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                    letterSpacing: 3,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x40E87984),
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  child: Container(
                                    key: ValueKey(_currentPhrase),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFE87984,
                                          ).withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _phrases[_currentPhrase],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Vazir',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 4),

                          // 👆 اشاره‌گر
                          Opacity(
                            opacity: _opacityAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, -_hintAnimation.value),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFFE87984,
                                      ).withOpacity(0.08),
                                    ),
                                    child: const Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'بکش بالا 💫',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Vazir',
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(flex: 1),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 🎨 نقاش لوگو
class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // هاله صورتی
    final pinkPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.8),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(centerX + 20, centerY - 12),
          radius: 48,
        ),
      );
    canvas.drawCircle(Offset(centerX + 20, centerY - 12), 48, pinkPaint);

    // هاله طلایی
    final goldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB347).withOpacity(0.7),
          const Color(0xFFFFB347).withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(centerX - 20, centerY + 12),
          radius: 42,
        ),
      );
    canvas.drawCircle(Offset(centerX - 20, centerY + 12), 42, goldPaint);

    // خط منحنی اتصال
    final linePaint = Paint()
      ..color = const Color(0x55E87984)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final path = Path();
    path.moveTo(centerX - 20, centerY + 12);
    path.cubicTo(
      centerX - 5,
      centerY - 18,
      centerX + 5,
      centerY + 18,
      centerX + 20,
      centerY - 12,
    );
    canvas.drawPath(path, linePaint);

    // قلب قرمز وسط
    final heartPaint = Paint()..color = AppColors.primary;
    final heartPath = Path();
    final hx = centerX, hy = centerY;
    heartPath.moveTo(hx, hy + 6);
    heartPath.cubicTo(hx, hy + 6, hx - 8, hy, hx - 8, hy - 5);
    heartPath.cubicTo(hx - 8, hy - 12, hx, hy - 16, hx, hy - 8);
    heartPath.cubicTo(hx, hy - 16, hx + 8, hy - 12, hx + 8, hy - 5);
    heartPath.cubicTo(hx + 8, hy, hx, hy + 6, hx, hy + 6);
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
