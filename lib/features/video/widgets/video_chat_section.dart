import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class VideoChatSection extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;
  final String videoTitle;

  const VideoChatSection({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.videoTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF1A0E2A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble, color: Colors.white38, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'چت همزمان',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontFamily: 'Vazir',
                  ),
                ),
                const Spacer(),
                if (messages.isNotEmpty)
                  Text(
                    '${messages.length} پیام',
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 11,
                      fontFamily: 'Vazir',
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.movie,
                          color: Colors.white12,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'چیزی بنویس تا باهم گپ بزنین 💬',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontFamily: 'Vazir',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _buildMessageBubble(context, msg);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final isMe = msg["isMe"] as bool;
    final type = msg["type"] as String? ?? "text";

    if (type == "reaction") {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.pinkAccent.withValues(alpha: 0.2)
                : Colors.white10,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(msg["text"], style: const TextStyle(fontSize: 28)),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                )
              : const LinearGradient(colors: [Colors.white12, Colors.white10]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg["text"],
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              msg["time"] ?? '',
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
