import 'package:flutter/material.dart';
import '../widgets/cycle_painter.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class PeriodMaleView extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final int periodLength;

  const PeriodMaleView({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
  });

  static const Color primaryPink = Color(0xFFFE4773);
  static const Color primaryPurple = Color(0xFF862AF5);

  @override
  Widget build(BuildContext context) {
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color cardColor = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
    final Color hintColor = appTheme?.textHint ?? const Color(0xFF888888);

    String moodEmoji, statusText, careText, predictionText;
    Color accentColor;

    if (currentDay <= periodLength) {
      moodEmoji = '😴';
      statusText = 'روزای حساسه...';
      careText =
          'الان احتمالاً خسته‌ست و نیاز به استراحت داره. یه دوش آب گرم، یه ماساژ گردن، یا یه شاخه گل می‌تونه معجزه کنه 🌸';
      predictionText = '${cycleLength - currentDay} روز تا پایان این دوره';
      accentColor = primaryPink;
    } else if (currentDay <= 13) {
      moodEmoji = '😊';
      statusText = 'حالش خوبه!';
      careText =
          'پر انرژی و سرحاله. بهترین وقت برای یه قرار عاشقونه، پیاده‌روی دونفره، یا برنامه‌ریزی آخر هفته‌ست ✨';
      predictionText =
          '${periodLength + cycleLength - currentDay} روز تا پریود بعدی';
      accentColor = primaryPurple;
    } else if (currentDay <= 16) {
      moodEmoji = '😍';
      statusText = 'روزای طلایی!';
      careText =
          'اوج انرژی و اعتماد به نفسشه. بهترین وقت برای خرید، مهمونی، و کارای مهمه. بهش بگو چقدر خوشگله! 💕';
      predictionText =
          '${periodLength + cycleLength - currentDay} روز تا پریود بعدی';
      accentColor = primaryPink;
    } else {
      moodEmoji = '😟';
      statusText = 'یه کم حساس شده...';
      careText =
          'ممکنه یه کم حساس‌تر باشه. شکلات تلخ، غذای خونگی، یه فیلم خوب، و یه عالمه محبت بهترین داروهاست 🍫🎬';
      predictionText =
          '${periodLength + cycleLength - currentDay} روز تا پریود بعدی';
      accentColor = primaryPurple;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildCircle(accentColor, cardColor),
          const SizedBox(height: 16),
          _buildStatusCard(moodEmoji, statusText, careText, accentColor,
              cardColor, textColor, hintColor),
          const SizedBox(height: 12),
          _buildActivitySuggestions(accentColor, cardColor, hintColor),
          const SizedBox(height: 12),
          _buildEmotionalTips(accentColor, cardColor, hintColor),
          const SizedBox(height: 12),
          _buildPredictionCard(
              predictionText, accentColor, cardColor, textColor, hintColor),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCircle(Color accentColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, // 👈 پویا
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: SizedBox(
        height: 180,
        width: 180,
        child: CustomPaint(
            painter: CyclePainter(
                currentDay: currentDay,
                cycleLength: cycleLength,
                periodLength: periodLength,
                phaseColor: accentColor)),
      ),
    );
  }

  Widget _buildStatusCard(String emoji, String title, String text,
      Color accentColor, Color cardColor, Color textColor, Color hintColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, // 👈
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 2)),
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor)),
        const SizedBox(height: 10),
        Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 12.5,
                color: hintColor, // 👈
                height: 1.6)),
      ]),
    );
  }

  Widget _buildActivitySuggestions(
      Color accentColor, Color cardColor, Color hintColor) {
    List<Map<String, String>> activities;
    if (currentDay <= periodLength) {
      activities = [
        {'emoji': '🛋️', 'text': 'ماراتن فیلم تو خونه'},
        {'emoji': '🍲', 'text': 'سوپ خونگی بپز'},
        {'emoji': '📖', 'text': 'براش کتاب بخون'}
      ];
    } else if (currentDay <= 13) {
      activities = [
        {'emoji': '🏃', 'text': 'پیاده‌روی دونفره'},
        {'emoji': '🍽️', 'text': 'رستوران مورد علاقش'},
        {'emoji': '🎨', 'text': 'یه کار هنری باهم'}
      ];
    } else {
      activities = [
        {'emoji': '🎬', 'text': 'سینما قرار بذار'},
        {'emoji': '🎵', 'text': 'کنسرت یا موزیک زنده'},
        {'emoji': '✈️', 'text': 'آخر هفته سفر برید'}
      ];
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, // 👈
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: accentColor.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🎯 پیشنهاد امروز',
            style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accentColor)),
        const SizedBox(height: 12),
        ...activities.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: accentColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Text(a['emoji']!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(a['text']!,
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      color: hintColor)) // 👈
            ]))),
      ]),
    );
  }

  Widget _buildEmotionalTips(
      Color accentColor, Color cardColor, Color hintColor) {
    final tips = [
      {
        'emoji': '🧠',
        'text': 'موقع پریود، سطح سروتونین پایین میاد. شکلات تلخ کمک می‌کنه!'
      },
      {'emoji': '💆', 'text': 'ماساژ گردن و شانه، گرفتگی عضلات رو کم می‌کنه'},
      {'emoji': '🛁', 'text': 'یه حموم آب گرم با نمک اپسوم، معجزه‌ست'},
      {'emoji': '😴', 'text': 'نیاز به خواب بیشتر داره، صبح‌ها زود بیدارش نکن'},
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, // 👈
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: accentColor.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🧠 نکات روانشناسی',
            style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accentColor)),
        const SizedBox(height: 12),
        ...tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['emoji']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(t['text']!,
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          color: hintColor, // 👈
                          height: 1.5)))
            ]))),
      ]),
    );
  }

  Widget _buildPredictionCard(String text, Color accentColor, Color cardColor,
      Color textColor, Color hintColor) {
    final progress = currentDay / cycleLength;
    final daysLeft = cycleLength - currentDay;
    String statusLabel, statusEmoji;
    if (currentDay <= periodLength) {
      statusLabel = 'در دوره پریود';
      statusEmoji = '🩸';
    } else if (daysLeft <= 3) {
      statusLabel = 'پریود نزدیکه';
      statusEmoji = '🔔';
    } else if (currentDay >= cycleLength - 16 &&
        currentDay <= cycleLength - 12) {
      statusLabel = 'روزای طلایی';
      statusEmoji = '✨';
    } else {
      statusLabel = 'همه چی آرومه';
      statusEmoji = '🌸';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor, // 👈
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: accentColor.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2)),
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ]),
      child: Column(children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(statusEmoji, style: const TextStyle(fontSize: 24))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(statusLabel,
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: accentColor)),
                const SizedBox(height: 2),
                Text(text,
                    style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 12,
                        color: hintColor)) // 👈
              ])),
          SizedBox(
              width: 56,
              height: 56,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: accentColor.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(progress * 100).toInt()}%',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: accentColor)),
                  Text('پیشرفت',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 7,
                          color: accentColor.withOpacity(0.6)))
                ]),
              ])),
        ]),
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: accentColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoChip(
                      '📅', 'امروز', 'روز $currentDay', accentColor, hintColor),
                  Container(
                      width: 1,
                      height: 40,
                      color: accentColor.withOpacity(0.1)),
                  _infoChip(
                      '⏳', 'مانده', '$daysLeft روز', accentColor, hintColor),
                  Container(
                      width: 1,
                      height: 40,
                      color: accentColor.withOpacity(0.1)),
                  _infoChip('🔄', 'طول سیکل', '$cycleLength روز', accentColor,
                      hintColor),
                ])),
        const SizedBox(height: 14),
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: accentColor.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('شروع',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 10,
                  color: hintColor.withOpacity(0.6))), // 👈
          Text('${(progress * 100).toInt()}%',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: accentColor)),
          Text('پایان',
              style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 10,
                  color: hintColor.withOpacity(0.6))), // 👈
        ]),
      ]),
    );
  }

  Widget _infoChip(String emoji, String label, String value, Color accentColor,
      Color hintColor) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: accentColor)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              fontFamily: 'Vazir', fontSize: 10, color: hintColor)), // 👈
    ]);
  }
}
