import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'event_data.dart';

class EventBanner extends StatelessWidget {
  final EventData? currentEvent;
  final List<EventData> allEvents;
  final int currentIndex;
  final String eventKey;

  const EventBanner({
    super.key,
    required this.currentEvent,
    required this.allEvents,
    this.currentIndex = 0,
    this.eventKey = 'event_0',
  });

  @override
  Widget build(BuildContext context) {
    if (currentEvent == null || allEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    final event = currentEvent!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آیکون رویداد
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: Center(
              child: Text(
                event.icon,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // متن رویداد
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.02, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey(eventKey),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'یادآوری',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      // 🔥 این بخش حذف شد - دیگه تاریخ زیرش نشون نمیده
                    ],
                  ),
                ),
                // نقاط نشانگر (اگر چند رویداد باشه)
                if (allEvents.length > 1) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List.generate(
                        allEvents.length,
                        (i) => AnimatedContainer(
                          key: ValueKey('dot_$i'),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: i == currentIndex ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: i == currentIndex
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // تعداد روز تا رویداد (این بمونه)
          if (event.isFuture) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${event.daysUntil()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'روز',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
