import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/services/couple_service.dart';
import 'package:flutter_application_1/core/providers/couple_cache_provider.dart';
import 'package:provider/provider.dart';

class MissYouButton extends StatefulWidget {
  final VoidCallback onPressed;

  const MissYouButton({super.key, required this.onPressed});

  @override
  State<MissYouButton> createState() => _MissYouButtonState();
}

class _MissYouButtonState extends State<MissYouButton>
    with SingleTickerProviderStateMixin {
  bool _isAnimating = false;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  final List<_FloatingHeart> _hearts = [];

  // رنگ‌های جدید برند
  static const Color primaryPink = Color(0xFFFE4773);
  static const Color primaryPurple = Color(0xFF862AF5);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 8),
    ]).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    _animController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isAnimating = false);
    });

    widget.onPressed();
    // 👇 اینو اضافه کن
    context.read<CoupleCacheProvider>().incrementMyMissYou();

    // ارسال به سرور و رفرش
    CoupleService.sendMissYou().then((_) {
      if (mounted) {
        context.read<CoupleCacheProvider>().refreshMissYouCounts();
      }
    });

    for (int i = 0; i < 12; i++) {
      _hearts.add(_FloatingHeart(index: i, angle: (i / 12) * 2 * pi));
    }

    setState(() {});

    Future.delayed(const Duration(milliseconds: 1200), () {
      _hearts.clear();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 170,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) {
                  return Transform.scale(scale: _scaleAnim.value, child: child);
                },
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    width: 170,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          primaryPink,
                          primaryPink
                        ], // یا می‌تونی یه گرادینت صورتی→بنفش بذاری
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPink.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'دلم برات تنگ شده',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Vazir',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ..._hearts.map(
              (heart) => Positioned.fill(
                child: Center(
                  child: IgnorePointer(child: _FireworkHeart(heart: heart)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingHeart {
  final int index;
  final double angle;

  _FloatingHeart({required this.index, required this.angle});
}

class _FireworkHeart extends StatefulWidget {
  final _FloatingHeart heart;

  const _FireworkHeart({required this.heart});

  @override
  State<_FireworkHeart> createState() => _FireworkHeartState();
}

class _FireworkHeartState extends State<_FireworkHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _distance;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _distance = Tween<double>(
      begin: 0,
      end: 60.0 + (widget.heart.index * 5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );

    _scale = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _rotation = Tween<double>(
      begin: 0,
      end: (widget.heart.index % 2 == 0 ? 1.5 : -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.heart.index * 30), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dx = _distance.value * cos(widget.heart.angle);
        final dy = _distance.value * sin(widget.heart.angle);

        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: _rotation.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Icon(
                  _getHeartIcon(widget.heart.index),
                  color: _getHeartColor(widget.heart.index),
                  size: _getHeartSize(widget.heart.index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getHeartIcon(int index) {
    const icons = [
      Icons.favorite,
      Icons.favorite_border,
      Icons.favorite,
      Icons.star,
      Icons.circle,
      Icons.favorite,
    ];
    return icons[index % icons.length];
  }

  // 🔥 پالت جدید قلب‌ها: صورتی، بنفش، سفید
  Color _getHeartColor(int index) {
    // لیست غیرثابت
    final colors = [
      _MissYouButtonState.primaryPink,
      _MissYouButtonState.primaryPurple,
      const Color(0xFFFFB6C1),
      const Color(0xFFFF69B4),
      Colors.white,
      _MissYouButtonState.primaryPurple.withOpacity(0.7),
    ];
    return colors[index % colors.length];
  }

  double _getHeartSize(int index) {
    const sizes = [14.0, 10.0, 18.0, 12.0, 8.0, 16.0];
    return sizes[index % sizes.length];
  }
}
