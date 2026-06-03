import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class VideoBottomBar extends StatefulWidget {
  final TextEditingController controller;
  final List<String> quickReactions;
  final Function(String) onSendMessage;
  final Function(String) onSendReaction;

  const VideoBottomBar({
    super.key,
    required this.controller,
    required this.quickReactions,
    required this.onSendMessage,
    required this.onSendReaction,
  });

  @override
  State<VideoBottomBar> createState() => _VideoBottomBarState();
}

class _VideoBottomBarState extends State<VideoBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.quickReactions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () =>
                      widget.onSendReaction(widget.quickReactions[index]),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.quickReactions[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic, color: Colors.pinkAccent, size: 22),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Vazir',
                  ),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: "پیام بنویس...",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Vazir',
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (text) => widget.onSendMessage(text),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () => widget.onSendMessage(widget.controller.text),
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
