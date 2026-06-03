import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/providers/notes_manager_provider.dart';

class NotesPartnerList extends StatelessWidget {
  final List<NoteItem> notes;

  const NotesPartnerList({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(
        child: Text(
          'پارتنر هنوز چیزی ننوشته... 💭',
          style: TextStyle(
              fontFamily: 'Vazir', fontSize: 13, color: Colors.black26),
        ),
      );
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildBubble(notes[index]);
      },
    );
  }

  Widget _buildBubble(NoteItem note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E6EF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                note.text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  color: note.isChecked
                      ? const Color(0xFFADADAD) // 🔥 رنگ خاکستری
                      : const Color(0xFF3E2723), // رنگ اصلی
                  decoration:
                      note.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.primaryDark, // 🔥 رنگ خط (صورتی)
                  decorationThickness: 2.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note.time,
                style: const TextStyle(
                    fontFamily: 'Vazir', fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
