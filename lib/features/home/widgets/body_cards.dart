import 'package:flutter/material.dart';
import 'love_letter.dart';
import 'suggestion_widget.dart';
import 'feeling_card.dart';
import 'miss_you_button.dart';
import 'location_card.dart';

class BodyCards extends StatelessWidget {
  final VoidCallback onMissYouPressed;

  const BodyCards({
    super.key,
    required this.onMissYouPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        const LoveLetter(),
        const SuggestionWidget(),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: FeelingCard(value: 0, showEmojis: true),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: FeelingCard(value: 0, showEmojis: false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MissYouButton(onPressed: onMissYouPressed),
        const SizedBox(height: 16),
        const LocationCard(),
        const SizedBox(height: 80),
      ],
    );
  }
}
