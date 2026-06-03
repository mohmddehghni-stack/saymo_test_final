import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/services/couple_service.dart';
import 'package:flutter_application_1/shared/services/socket_service.dart';
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

  @override
  Widget build(BuildContext context) {
    if (!widget.showEmojis) {
      return _buildPartnerCard(context);
    }
    return _buildMyCard();
  }

  // =============================================
  // 🔥 کارت خودم
  // =============================================
  Widget _buildMyCard() {
    final cache = context.watch<CoupleCacheProvider>();
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfacePrimary, AppColors.periodBackground],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: Color.fromARGB(240, 240, 240, 236),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _emojiButton(0, AnimatedEmojis.smileWithBigEyes),
                _emojiButton(1, AnimatedEmojis.bigFrown),
                _emojiButton(2, AnimatedEmojis.angry),
                _emojiButton(3, AnimatedEmojis.cooking),
                _emojiButton(4, AnimatedEmojis.neutralFace),
                _emojiButton(5, AnimatedEmojis.fire),
              ],
            ),
          ),
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
                      color: AppColors.primaryDark,
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
  // 🔥 کارت پارتنر
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surfacePrimary, AppColors.periodBackground],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.shadowLight, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // 🔥 هدر: آواتار + شمارنده
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0x26E87984),
                  child: Icon(Icons.person, size: 28, color: AppColors.primary),
                ),
                const Spacer(),
                if (cache.missYouCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
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
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '💕 دلتنگی',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 🔥 محتوا: ایموجی + حس
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
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            partnerMessage,
                            style: const TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 14,
                              color: AppColors.primary,
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
  // 🔥 متدهای کمکی
  // =============================================
  Widget _emojiButton(int index, AnimatedEmojiData emoji) {
    final isSelected = selectedEmoji == index;
    return GestureDetector(
      onTap: () {
        if (selectedEmoji != index) {
          _showConfirmDialog(index, Icons.favorite, AppColors.primary);
        } else {
          setState(() {
            selectedEmoji = null;
            _selectedAnimatedEmoji = null;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: AnimatedEmoji(emoji, size: 20),
      ),
    );
  }

  void _showConfirmDialog(int index, IconData icon, Color color) {
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
        backgroundColor: AppColors.surfacePrimary,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedEmoji(feelingEmojis[index], size: 70),
              const SizedBox(height: 16),
              const Text('می‌خوای بهش بگی:',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('«${feelingNames[index]}»',
                  style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              const Text('این حس برای عشقت ارسال بشه؟',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: AppColors.textHint)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textHint,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('نه',
                          style: TextStyle(fontFamily: 'Vazir', fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedEmoji = index;
                          _selectedAnimatedEmoji = feelingEmojis[index];
                        });
                        _showSentMessage(feelingNames[index]);
                      },
                      child: const Text('آره، بفرست ❤️',
                          style: TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 14,
                              color: Colors.white)),
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
              backgroundColor: AppColors.primary,
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

  void _showSentMessage(String feeling) {
    CoupleService.sendFeeling(feeling);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feeling برای عشقت ارسال شد! ❤️',
            style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: AppColors.primary,
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
