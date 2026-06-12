import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // آیکن فلش (با رنگ راهنما)
              Icon(
                Icons.chevron_left,
                color: appTheme?.textHint ?? Colors.black38,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Vazir',
                    // 👇 متن اصلی (نام، شماره و...)
                    color: appTheme?.textPrimary ?? Colors.black,
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  // 👇 متن برچسب (موبایل، جنسیت و...)
                  color: appTheme?.textHint ?? Colors.black45,
                  fontFamily: 'Vazir',
                ),
              ),
              const SizedBox(width: 8),
              // آیکن اصلی (با رنگ راهنما)
              Icon(
                icon,
                size: 22,
                color: appTheme?.textHint ?? Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
