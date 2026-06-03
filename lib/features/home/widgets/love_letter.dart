import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/services/couple_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/couple_cache_provider.dart';

class LoveLetter extends StatefulWidget {
  const LoveLetter({super.key});

  @override
  State<LoveLetter> createState() => _LoveLetterState();
}

class _LoveLetterState extends State<LoveLetter>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _isSent = false;

  final TextEditingController _controller = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  List<Map<String, dynamic>> _letters = [];

  Future<void> _loadLetters() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/couple/love-letters'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() =>
            _letters = List<Map<String, dynamic>>.from(data['letters'] ?? []));
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _loadLetters();
    SocketService.addHandler(_handleLoveLetter); // 🔥 اینو اضافه کن
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleLoveLetter);
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLoveLetter(Map<String, dynamic> data) {
    if (data['action'] == 'love_letter_received') {
      if (!mounted) return;
      _loadLetters();
      _showReceivedDialog(data['text'] ?? '');
    }
  }

  void _toggleEnvelope() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _showReceivedDialog(String text) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.surfacePrimary,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // انیمیشن قلب تپنده
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark]),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.mail, color: Colors.white, size: 35),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('📨 یه نامه برات اومد!',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('خوندم ❤️',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 16,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendLetter() {
    if (_controller.text.trim().isEmpty) return;

    CoupleService.sendLoveLetter(_controller.text.trim());

    setState(() => _isSent = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: AppColors.surfacePrimary,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.favorite, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 16),
                const Text('نامه‌ات ارسال شد! 💌',
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('عشقت به دستش می‌رسه... 🕊️',
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 13,
                        color: AppColors.textHint)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          _isOpen = false;
                          _isSent = false;
                        });
                        _controller.clear();
                      }
                    },
                    child: const Text('باشه 😊',
                        style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isOpen ? null : _toggleEnvelope,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                _isOpen ? const Color(0xFFFFF8E7) : AppColors.periodBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: _isOpen ? _buildOpenEnvelope() : _buildClosedEnvelope(),
        ),
      ),
    );
  }

  Widget _buildClosedEnvelope() {
    final cache = context.read<CoupleCacheProvider>();
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('نامه عاشقانه',
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
                SizedBox(height: 4),
                Text('برای نوشتن کلیک کن... ✍️',
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 11,
                        color: AppColors.textHint)),
              ],
            ),
          ),
          // 🔥 آیکن پاکت با انیمیشن
          // 🔥 آیکن پاکت به عنوان دکمه
          GestureDetector(
            onTap: () {
              cache.markLettersRead(); // 🔥 آلارم رو خاموش کن
              _showLettersList();
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: cache.hasNewLetters ? 0.8 : 1.0, // 🔥 از cache بخون
                end: cache.hasNewLetters ? 1.3 : 1.0,
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cache.hasNewLetters
                          ? Colors.red.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          cache.hasNewLetters
                              ? Icons.mark_email_unread
                              : Icons.mail_outline,
                          color: cache.hasNewLetters
                              ? Colors.red
                              : AppColors.primary,
                          size: 30,
                        ),
                        if (cache.hasNewLetters)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLettersList() {
    final cache = context.read<CoupleCacheProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('💌 نامه‌های دریافتی',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                  child: _letters.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📭', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 8),
                              Text('هنوز نامه‌ای نداری',
                                  style: TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 14,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _letters.length,
                          itemBuilder: (context, index) {
                            final letter = _letters[index];
                            return GestureDetector(
                              onTap: () {
                                // 🔥 باز کردن نامه توی دیالوگ بزرگ
                                _showLetterDetail(letter);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.mail,
                                            color: AppColors.primary, size: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          'نامه ${_letters.length - index}',
                                          style: const TextStyle(
                                              fontFamily: 'Vazir',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryDark),
                                        ),
                                        const Spacer(),
                                        Text(
                                          letter['created_at'] ?? '',
                                          style: const TextStyle(
                                              fontFamily: 'Vazir',
                                              fontSize: 11,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      letter['text'] ?? '',
                                      style: const TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 15,
                                          height: 1.6),
                                      textDirection: TextDirection.rtl,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ],
          ),
        );
      },
    );

    // 🔥 بعد از باز کردن، آلارم رو خاموش کن
    cache.markLettersRead();
  }

  void _showLetterDetail(Map<String, dynamic> letter) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final value = animation.value;

              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: _buildAnimatedEnvelope(letter, value),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedEnvelope(Map<String, dynamic> letter, double value) {
    final scale = 0.5 + (value * 0.5);
    final opacity = value < 0.3 ? 0.0 : (value - 0.3) / 0.7;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // خطوط دفتر
                ...List.generate(20, (index) {
                  return Positioned(
                    top: 16.0 + (index * 28),
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE8D5B7).withOpacity(0.4),
                    ),
                  );
                }),

                // حاشیه قرمز
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 32,
                  child:
                      Container(width: 1.5, color: Colors.red.withOpacity(0.2)),
                ),

                // متن
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(42, 20, 20, 20),
                    child: AnimatedOpacity(
                      opacity: opacity,
                      duration: const Duration(milliseconds: 400),
                      child: AnimatedSlide(
                        offset: Offset(0, value < 0.5 ? 0.2 : 0.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        child: SingleChildScrollView(
                          child: Text(
                            letter['text'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 16,
                              height: 2.0,
                              color: AppColors.textPrimary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔥 دکمه برگشت - بالا چپ
                Positioned(
                  top: 12,
                  left: 12,
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpenEnvelope() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text('نامه من به تو...',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
              const Spacer(),
              GestureDetector(
                onTap: _toggleEnvelope,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.close,
                      color: AppColors.primary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Stack(
              children: [
                ...List.generate(6, (index) {
                  return Positioned(
                    top: 20.0 + (index * 22),
                    left: 12,
                    right: 12,
                    child: Container(
                        height: 1, color: AppColors.primary.withOpacity(0.1)),
                  );
                }),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    maxLines: 5,
                    style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.55),
                    decoration: const InputDecoration(
                      hintText: 'از دل بنویس... ❤️',
                      hintStyle: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 13,
                          color: AppColors.textHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: _sendLetter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ارسال',
                          style: TextStyle(
                              fontFamily: 'Vazir',
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
