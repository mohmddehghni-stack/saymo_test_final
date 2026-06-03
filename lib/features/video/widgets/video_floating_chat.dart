import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class VideoFloatingChat extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final VoidCallback onExitFullScreen;

  const VideoFloatingChat({
    super.key,
    required this.messages,
    required this.onExitFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Text(
                      'پیامی نیست...',
                      style: TextStyle(
                        color: Colors.white38,
                        fontFamily: 'Vazir',
                        fontSize: 12,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isReaction = msg["type"] == "reaction";
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isReaction && msg["isMe"] == false)
                                const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.pinkAccent,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              if (!isReaction && msg["isMe"] == false)
                                const SizedBox(width: 6),
                              Text(
                                msg["text"],
                                style: TextStyle(
                                  color:
                                      isReaction ? Colors.yellow : Colors.white,
                                  fontFamily: 'Vazir',
                                  fontSize: isReaction ? 18 : 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            GestureDetector(
              onTap: onExitFullScreen,
              child: const Icon(
                Icons.fullscreen_exit,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
