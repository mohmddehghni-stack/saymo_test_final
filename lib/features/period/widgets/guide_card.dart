import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class GuideCard extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final int periodLength;

  const GuideCard({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.periodLength,
  });

  @override
  Widget build(BuildContext context) {
    final ovulationDay = cycleLength - 14;
    final fertileStart = ovulationDay - 5;
    final fertileEnd = ovulationDay + 1;

    String phase, tip, emoji, accentTitle;
    IconData icon;
    Color accentColor;

    if (currentDay <= periodLength) {
      phase = 'فاز قاعدگی';
      accentTitle = '🩸';
      emoji = '😴';
      icon = Icons.water_drop_outlined;
      accentColor = AppColors.primary;
      tip =
          'روزای خونریزی. استراحت کن، آب زیاد بنوش، به بدنت گوش بده. دوش آب گرم و مایعات گرم معجزه می‌کنه. ${periodLength - currentDay > 0 ? "${periodLength - currentDay} روز دیگه تموم میشه!" : "امروز روز آخره!"}';
    } else if (currentDay < fertileStart) {
      phase = 'فاز فولیکولار';
      accentTitle = '🌱';
      emoji = '😊';
      icon = Icons.fitness_center_outlined;
      accentColor = const Color(0xFF5B8DEF);
      tip =
          'انرژیت داره برمی‌گرده! استروژن در حال افزایشه و احساس بهتری داری. وقت خوبیه برای ورزش سبک، برنامه‌ریزی کارهای مهم، و معاشرت با دوستامون.';
    } else if (currentDay <= fertileEnd) {
      phase = 'فاز تخمک‌گذاری';
      accentTitle = '🥚';
      emoji = '😍';
      icon = Icons.favorite_outline;
      accentColor = const Color(0xFFD4A017);
      tip =
          'اوج انرژی، اعتماد به نفس، و جذابیت! استروژن و تستوسترون در بالاترین سطح. بهترین روز برای قرارهای عاشقونه، خرید لباس جدید، و کارای خلاقانه.';
    } else if (currentDay <= cycleLength - 7) {
      phase = 'فاز لوتئال اولیه';
      accentTitle = '🌙';
      emoji = '😌';
      icon = Icons.self_improvement_outlined;
      accentColor = const Color(0xFF9B59B6);
      tip =
          'پروژسترون در حال افزایشه. هنوز انرژی خوبی داری ولی یواش یواش بدنت آماده می‌شه. کارهای نیمه‌تموم رو جمع کن، به تغذیه‌ات برس.';
    } else {
      phase = 'فاز PMS';
      accentTitle = '🌧️';
      emoji = '😟';
      icon = Icons.spa_outlined;
      accentColor = const Color(0xFF888888);
      tip =
          'ممکنه یه کم حساس‌تر و خسته‌تر باشی. شکلات تلخ، فیلم خوب، یه پتوی نرم، و مهربونی با خودت بهترین داروهاست. ${cycleLength - currentDay} روز دیگه پریود میشی! 💪';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── هدر ───
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$accentTitle $phase',
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'روز $currentDay از $cycleLength',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 10,
                    color: accentColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ─── محتوا ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 12.5,
                    color: Color(0xFF888888),
                    height: 1.7,
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
