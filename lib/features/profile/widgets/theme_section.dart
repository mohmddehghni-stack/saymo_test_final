import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/theme_provider.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme?.cardBackground ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (appTheme?.shadowColor ?? Colors.black).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // آیکن پویا (خورشید/ماه) با چرخش
          AnimatedRotation(
            duration: const Duration(milliseconds: 500),
            turns: isDark ? 1.0 : 0.0,
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // متن راهنما
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDark ? 'تم تاریک' : 'تم روشن',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: appTheme?.textPrimary ?? Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDark ? 'حالت شب' : 'حالت روز',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 12,
                    color: appTheme?.textHint ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // 🔥 Switch سفارشی با آیکن ماه/خورشید
          _CustomAnimatedSwitch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) {
              themeProvider.setThemeMode(
                val ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================
// 🔥 Switch سفارشی با آیکن داخل دایره
// =============================================
class _CustomAnimatedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomAnimatedSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_CustomAnimatedSwitch> createState() => _CustomAnimatedSwitchState();
}

class _CustomAnimatedSwitchState extends State<_CustomAnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 2),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _controller.forward(from: 0.0);
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkActive = widget.value; // true = تم تاریک روشنه

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDarkActive ? AppColors.primary : Colors.grey.shade300,
        ),
        child: Align(
          alignment:
              isDarkActive ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    // 🔥 آیکن داخل دایره: وقتی دارک فعاله → ماه، وقتی روشن فعاله → خورشید
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isDarkActive
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        key: ValueKey(isDarkActive),
                        size: 14,
                        color: isDarkActive ? AppColors.primary : Colors.orange,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
