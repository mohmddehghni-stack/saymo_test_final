import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class FanItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FanItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class SpeedFanFAB extends StatefulWidget {
  final List<FanItem> items;
  final Color fabColor;
  final double fabSize;
  final double itemSize;
  final double radius;
  final IconData? openIcon;
  final IconData? closeIcon;
  final String? openEmoji;
  final String? closeEmoji;
  final void Function(bool isOpen)? onOpenChanged;

  const SpeedFanFAB({
    super.key,
    required this.items,
    this.fabColor = const Color(0xFFE8456B),
    this.fabSize = 56,
    this.itemSize = 48,
    this.radius = 100,
    this.openIcon,
    this.closeIcon,
    this.openEmoji,
    this.closeEmoji,
    this.onOpenChanged,
  });

  @override
  State<SpeedFanFAB> createState() => SpeedFanFABState();
}

class SpeedFanFABState extends State<SpeedFanFAB>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: math.pi / 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // 👈 اینو اضافه کن - گوش دادن به وضعیت انیمیشن
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onOpenChanged?.call(_isOpen);
  }

  void close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
      });
      widget.onOpenChanged?.call(false);
    }
  }

  bool get isOpen => _isOpen;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.fabSize + widget.radius,
      height: widget.fabSize + widget.radius,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // دکمه‌های فرعی
          ..._buildFanItems(),
          // دکمه اصلی
          Positioned(
            bottom: 0,
            left: 0,
            child: _buildMainButton(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFanItems() {
    final count = widget.items.length;
    final reversedItems = widget.items.reversed.toList();

    return List.generate(count, (index) {
      final delay = index * 0.12; // 👈 نرم‌تر
      final itemAnimation = CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, delay + 0.5,
            curve: Curves.easeOutCubic), // 👈 نرم‌تر
      );

      final angle = (math.pi / 2) * (1 - (index / (count - 1 + 0.001)));

      final x = widget.radius * math.cos(angle);
      final y = widget.radius * math.sin(angle);

      return AnimatedBuilder(
        animation: itemAnimation,
        builder: (context, child) {
          return Positioned(
            bottom: y * itemAnimation.value,
            left: x * itemAnimation.value,
            child: Transform.scale(
              scale: itemAnimation.value,
              child: Opacity(
                opacity: itemAnimation.value.clamp(0.0, 1.0),
                child: child,
              ),
            ),
          );
        },
        child: _buildFanItem(reversedItems[index]),
      );
    });
  }

  Widget _buildFanItem(FanItem item) {
    return GestureDetector(
      onTap: () {
        close();
        item.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.itemSize,
            height: widget.itemSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(item.icon,
                  color: Colors.white, size: widget.itemSize * 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Vazir',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: widget.fabSize,
            height: widget.fabSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [widget.fabColor, widget.fabColor.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.fabColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded, // 👈 همیشه +
                color: Colors.white,
                size: widget.fabSize * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainIcon() {
    // وقتی بازه → openIcon (ضربدر)
    if (_isOpen) {
      if (widget.openIcon != null) {
        return Icon(widget.openIcon,
            color: Colors.white, size: widget.fabSize * 0.45);
      }
      if (widget.openEmoji != null) {
        return Text(widget.openEmoji!,
            style: TextStyle(fontSize: widget.fabSize * 0.4));
      }
      return Icon(Icons.close_rounded,
          color: Colors.white, size: widget.fabSize * 0.45);
    }

    // وقتی بسته‌س → closeIcon (بعلاوه)
    if (widget.closeIcon != null) {
      return Icon(widget.closeIcon,
          color: Colors.white, size: widget.fabSize * 0.45);
    }
    if (widget.closeEmoji != null) {
      return Text(widget.closeEmoji!,
          style: TextStyle(fontSize: widget.fabSize * 0.4));
    }
    return Icon(Icons.add_rounded,
        color: Colors.white, size: widget.fabSize * 0.45);
  }
}
