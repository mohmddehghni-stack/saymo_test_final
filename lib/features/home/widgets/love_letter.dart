import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/services/couple_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/couple_cache_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

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

  // رنگ‌های برند (ثابت می‌مونن)
  static const Color primaryPink = Color(0xFFFE4773);
  static const Color primaryPurple = Color(0xFF862AF5);
  // رنگ‌های پیش‌فرض روشن (برای حالت null امن)
  static const Color fallbackWhite = Colors.white;
  static const Color fallbackDarkText = Color(0xFF1A1A2E);
  static const Color fallbackGreyText = Color(0xFF8E8E98);

  // ...

  @override
  Widget build(BuildContext context) {
    // 🔥 گرفتن AppTheme و وضعیت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _isOpen ? null : _toggleEnvelope,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            // پس‌زمینه: در حالت باز از letterBg (کاغذی)، در حالت بسته از softPinkBg
            // در تم تاریک هر دو به cardBackground تبدیل می‌شوند
            color: _isOpen
                ? (isDark
                    ? (appTheme?.cardBackground ?? const Color(0xFF1E1E1E))
                    : const Color(0xFFF9FA))
                : (isDark
                    ? (appTheme?.cardBackground ?? const Color(0xFF1E1E1E))
                    : const Color(0xFFFDF4F5)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: primaryPink.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: _isOpen ? _buildOpenEnvelope() : _buildClosedEnvelope(),
        ),
      ),
    );
  }

  // =============================================
  // پاکت بسته
  // =============================================
  Widget _buildClosedEnvelope() {
    // داخل این متد هم از Theme استفاده می‌کنیم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: primaryPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('نامه عاشقانه',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: appTheme?.textPrimary ?? fallbackDarkText)),
                const SizedBox(height: 4),
                Text('برای نوشتن کلیک کن... ✍️',
                    style: TextStyle(
                        fontSize: 11,
                        color: appTheme?.textHint ?? fallbackGreyText)),
              ],
            ),
          ),
          // دکمه پاکت (بدون تغییر)
          GestureDetector(
            onTap: () {
              cache.markLettersRead();
              _showLettersList();
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: cache.hasNewLetters ? 0.8 : 1.0,
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
                          ? primaryPurple.withOpacity(0.1)
                          : primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          cache.hasNewLetters
                              ? Icons.mark_email_unread
                              : Icons.mail_outline,
                          color:
                              cache.hasNewLetters ? primaryPurple : primaryPink,
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
                                color: primaryPurple,
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

  // =============================================
  // دریافت نامه (دیالوگ)
  // =============================================
  void _showReceivedDialog(String text) {
    // این متد context خود State رو داره، پس می‌تونیم مستقیماً Theme رو بگیریم
    final appTheme = Theme.of(context).extension<AppTheme>();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: appTheme?.cardBackground ?? fallbackWhite,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                            colors: [primaryPink, primaryPurple]),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.mail, color: Colors.white, size: 35),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('📨 یه نامه برات اومد!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appTheme?.textPrimary ?? fallbackDarkText)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // پس‌زمینه نامه: در تم روشن بنفش کمرنگ، در تم تاریک یه رنگ تیره‌تر
                  color: appTheme != null
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? primaryPurple.withOpacity(0.1)
                          : const Color(0xFFF2E8FF))
                      : const Color(0xFFF2E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 14,
                      color: appTheme?.textPrimary ?? fallbackDarkText,
                      height: 1.5),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('خوندم ❤️',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================
  // ارسال نامه
  // =============================================
  void _sendLetter() {
    if (_controller.text.trim().isEmpty) return;

    CoupleService.sendLoveLetter(_controller.text.trim());

    setState(() => _isSent = true);

    final appTheme = Theme.of(context).extension<AppTheme>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: appTheme?.cardBackground ?? fallbackWhite,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    gradient:
                        LinearGradient(colors: [primaryPink, primaryPurple]),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.favorite, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 16),
                Text('نامه‌ات ارسال شد! 💌',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appTheme?.textPrimary ?? fallbackDarkText)),
                const SizedBox(height: 8),
                Text('عشقت به دستش می‌رسه... 🕊️',
                    style: TextStyle(
                        fontSize: 13,
                        color: appTheme?.textHint ?? fallbackGreyText)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
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

  // =============================================
  // لیست نامه‌ها (BottomSheet)
  // =============================================
  void _showLettersList() {
    final cache = context.read<CoupleCacheProvider>();
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // مهم: برای پس‌زمینه شفاف
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: appTheme?.cardBackground ?? fallbackWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
              Text('💌 نامه‌های دریافتی',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appTheme?.textPrimary ?? fallbackDarkText)),
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
                                      fontSize: 14,
                                      color: appTheme?.textHint ??
                                          fallbackGreyText)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _letters.length,
                          itemBuilder: (context, index) {
                            final letter = _letters[index];
                            return GestureDetector(
                              onTap: () => _showLetterDetail(letter),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? (appTheme?.cardBackground ??
                                          const Color(0xFF1E1E1E))
                                      : const Color(0xFFF2E8FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.mail,
                                            color: primaryPurple, size: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          'نامه ${_letters.length - index}',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: primaryPink),
                                        ),
                                        const Spacer(),
                                        Text(
                                          letter['created_at'] ?? '',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: appTheme?.textHint ??
                                                  fallbackGreyText),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      letter['text'] ?? '',
                                      style: TextStyle(
                                          fontSize: 15,
                                          height: 1.6,
                                          color: appTheme?.textPrimary ??
                                              fallbackDarkText),
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

    cache.markLettersRead();
  }

  // =============================================
  // نامه تمام‌صفحه (بدون تغییر، رنگ‌ها ثابت هستند)
  // =============================================
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
    SocketService.addHandler(_handleLoveLetter);
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
            color: const Color(0xFFFFFDF5), // رنگ کاغذ بدون تغییر
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
                ...List.generate(20, (index) {
                  return Positioned(
                    top: 16.0 + (index * 28),
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 1,
                      color: primaryPurple.withOpacity(0.08),
                    ),
                  );
                }),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 32,
                  child: Container(
                      width: 1.5, color: primaryPink.withOpacity(0.3)),
                ),
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
                              fontSize: 16,
                              height: 2.0,
                              color: fallbackDarkText,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
    final appTheme = Theme.of(context).extension<AppTheme>();
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: primaryPink, size: 18),
              const SizedBox(width: 8),
              Text('نامه من به تو...',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appTheme?.textPrimary ?? fallbackDarkText)),
              const Spacer(),
              GestureDetector(
                onTap: _toggleEnvelope,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.close, color: primaryPink, size: 16),
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
              border: Border.all(color: primaryPink.withOpacity(0.2)),
            ),
            child: Stack(
              children: [
                ...List.generate(6, (index) {
                  return Positioned(
                    top: 20.0 + (index * 22),
                    left: 12,
                    right: 12,
                    child: Container(
                        height: 1, color: primaryPurple.withOpacity(0.1)),
                  );
                }),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    maxLines: 5,
                    style: TextStyle(
                        fontSize: 14,
                        color: appTheme?.textPrimary ?? fallbackDarkText,
                        height: 1.55),
                    decoration: InputDecoration(
                      hintText: 'از دل بنویس... ❤️',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: appTheme?.textHint ?? fallbackGreyText),
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
                        colors: [primaryPink, primaryPurple]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: primaryPink.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ارسال',
                          style: TextStyle(
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

  void _handleLoveLetter(Map<String, dynamic> data) {
    if (data['action'] == 'love_letter_received') {
      if (!mounted) return;
      _loadLetters();
      _showReceivedDialog(data['text'] ?? '');
    }
  }

  @override
  void dispose() {
    SocketService.removeHandler(_handleLoveLetter);
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }
}
