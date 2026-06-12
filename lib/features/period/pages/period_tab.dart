import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/period_provider.dart';
import 'period_female_view.dart';
import 'period_male_view.dart';
import 'package:flutter_application_1/features/period/pages/period_setup_view.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class PeriodTab extends StatelessWidget {
  final bool isFemale;

  const PeriodTab({super.key, required this.isFemale});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PeriodProvider>();
    final appTheme = Theme.of(context).extension<AppTheme>();

    if (isFemale) {
      if (!pp.isSetupDone) {
        return const PeriodSetupPrompt();
      }
      return const PeriodFemaleView();
    }

    if (!pp.partnerDataLoaded) {
      Future.microtask(() => pp.loadPartnerData());
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (!pp.hasPartner) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💔', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'هنوز با کسی کانکت نشدی!',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 16,
                // 👇 متن راهنما از AppTheme
                color: appTheme?.textHint ?? Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (!pp.isPartnerSetupDone) {
      return const PartnerNotSetupView();
    }

    return PeriodMaleView(
      currentDay: pp.partnerCurrentDay,
      cycleLength: pp.partnerCycleLength,
      periodLength: pp.partnerPeriodLength,
    );
  }
}

class PeriodSetupPrompt extends StatelessWidget {
  const PeriodSetupPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👩‍🦰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'اول تنظیمات پریود رو انجام بده',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 16,
              // 👇 متن اصلی از AppTheme
              color: appTheme?.textPrimary ?? const Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PeriodSetupView(
                    onCompleted: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
            child: const Text('شروع تنظیمات'),
          ),
        ],
      ),
    );
  }
}

class PartnerNotSetupView extends StatelessWidget {
  const PartnerNotSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤷‍♂️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'پارتنرت هنوز تنظیمات پریود رو انجام نداده',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 16,
              // 👇
              color: appTheme?.textHint ?? Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ازش بخواه اطلاعاتش رو وارد کنه 😊',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              // 👇
              color: (appTheme?.textHint ?? Colors.grey).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
