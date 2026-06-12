import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/services/couple_service.dart';
import 'package:flutter_application_1/core/providers/couple_cache_provider.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';

class FeelingCard extends StatefulWidget {
  final int value;
  final bool showEmojis;

  const FeelingCard({super.key, required this.value, this.showEmojis = false});

  @override
  State<FeelingCard> createState() => _FeelingCardState();
}

class _FeelingCardState extends State<FeelingCard> {
  int? selectedEmoji;
  AnimatedEmojiData? _selectedAnimatedEmoji;

  static const Color primaryPink = Color(0xFFFE4773);
  static const Color primaryPurple = Color(0xFF862AF5);

  @override
  Widget build(BuildContext context) {
    if (!widget.showEmojis) {
      return _buildPartnerCard(context);
    }
    return _buildMyCard();
  }

  // =============================================
  // 🔥 کارت خودم (تم صورتی)
  // =============================================
  Widget _buildMyCard() {
    final cache = context.watch<CoupleCacheProvider>();
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ردیف ایموجی‌ها
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF5F5F5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _emojiButton(0, AnimatedEmojis.smileWithBigEyes, primaryPink),
                _emojiButton(1, AnimatedEmojis.bigFrown, primaryPink),
                _emojiButton(2, AnimatedEmojis.angry, primaryPink),
                _emojiButton(3, AnimatedEmojis.cooking, primaryPink),
                _emojiButton(4, AnimatedEmojis.neutralFace, primaryPink),
                _emojiButton(5, AnimatedEmojis.fire, primaryPink),
              ],
            ),
          ),
          // عدد بزرگ و ایموجی
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cache.myMissYouCount.toString(),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: primaryPink,
                    ),
                  ),
                  if (_selectedAnimatedEmoji != null) ...[
                    const SizedBox(height: 6),
                    AnimatedEmoji(_selectedAnimatedEmoji!, size: 50),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // 🔥 کارت پارتنر (تم بنفش)
  // =============================================
  Widget _buildPartnerCard(BuildContext context) {
    final cache = context.watch<CoupleCacheProvider>();
    _checkMissYou(cache, context);

    final feeling = cache.partnerFeeling;
    AnimatedEmojiData? partnerEmoji;
    String partnerMessage = '';

    if (feeling.contains('خوشحال')) {
      partnerEmoji = AnimatedEmojis.smileWithBigEyes;
      partnerMessage = 'حالم خیلی خوبه! 😊';
    } else if (feeling.contains('ناراحت')) {
      partnerEmoji = AnimatedEmojis.bigFrown;
      partnerMessage = 'یه کم ناراحتم... 😢';
    } else if (feeling.contains('عصبانی')) {
      partnerEmoji = AnimatedEmojis.angry;
      partnerMessage = 'الآن عصبانیم! 😤';
    } else if (feeling.contains('گرسنه')) {
      partnerEmoji = AnimatedEmojis.cooking;
      partnerMessage = 'وای چقدر گرسنمه! 🍕';
    } else if (feeling.contains('حوصلهم') || feeling.contains('بی‌حوصله')) {
      partnerEmoji = AnimatedEmojis.neutralFace;
      partnerMessage = 'حوصلهم سر رفته... 😐';
    } else if (feeling.contains('انرژی') || feeling.contains('پرجنب‌وجوش')) {
      partnerEmoji = AnimatedEmojis.fire;
      partnerMessage = 'پر از انرژی‌ام! ⚡';
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // هدر: آواتار + شمارنده
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // آواتار با تم بنفش
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0x1F862AF5), // بنفش ۱۲٪
                  child: Icon(Icons.person, size: 28, color: primaryPurple),
                ),
                const Spacer(),
                if (cache.missYouCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryPurple.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${cache.missYouCount}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '💕 دلتنگی',
                          style: TextStyle(fontSize: 10, color: primaryPurple),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // حس و حال
          Expanded(
            child: Center(
              child: feeling.isNotEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (partnerEmoji != null)
                          AnimatedEmoji(partnerEmoji, size: 52),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: primaryPurple
                                .withOpacity(0.05), // بنفش خیلی کمرنگ
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            partnerMessage,
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 14,
                              color: primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🤷‍♂️', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'هنوز حسی اعلام نکرده...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // 🔥 دکمه ایموجی (با رنگ پویا)
  // =============================================
  Widget _emojiButton(int index, AnimatedEmojiData emoji, Color activeColor) {
    final isSelected = selectedEmoji == index;
    return GestureDetector(
      onTap: () {
        if (selectedEmoji != index) {
          _showConfirmDialog(index, activeColor);
        } else {
          setState(() {
            selectedEmoji = null;
            _selectedAnimatedEmoji = null;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:
              isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedEmoji(emoji, size: 22),
      ),
    );
  }

  // =============================================
  // 🔥 دیالوگ ارسال حس (با رنگ داده شده)
  // =============================================
  void _showConfirmDialog(int index, Color themeColor) {
    final feelingNames = [
      'خوشحالم 😊',
      'ناراحتم 😢',
      'عصبانی‌ام 😠',
      'گرسنمه 🍕',
      'حوصلهم سر رفته 😐',
      'پر انرژی‌ام 🔥',
    ];
    final feelingEmojis = [
      AnimatedEmojis.smileWithBigEyes,
      AnimatedEmojis.bigFrown,
      AnimatedEmojis.angry,
      AnimatedEmojis.cooking,
      AnimatedEmojis.neutralFace,
      AnimatedEmojis.fire,
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedEmoji(feelingEmojis[index], size: 70),
              const SizedBox(height: 16),
              const Text('می‌خوای بهش بگی:',
                  style: TextStyle(fontSize: 16, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              Text('«${feelingNames[index]}»',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeColor)),
              const SizedBox(height: 8),
              const Text('این حس برای عشقت ارسال بشه؟',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8E8E98))),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('نه', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedEmoji = index;
                          _selectedAnimatedEmoji = feelingEmojis[index];
                        });
                        _showSentMessage(feelingNames[index], themeColor);
                      },
                      child: const Text('آره، بفرست ❤️',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkMissYou(CoupleCacheProvider cache, BuildContext context) {
    if (cache.lastMissYou.isNotEmpty) {
      try {
        final lastTime = DateTime.parse(cache.lastMissYou);
        final diff = DateTime.now().difference(lastTime).inSeconds;
        if (diff < 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Text('💕', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text('عشقت دلش برات تنگ شده!',
                    style: TextStyle(fontFamily: 'Vazir')),
              ]),
              backgroundColor: primaryPink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (_) {}
    }
  }

  void _showSentMessage(String feeling, Color color) {
    CoupleService.sendMood(feeling);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feeling برای عشقت ارسال شد! ❤️',
            style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
