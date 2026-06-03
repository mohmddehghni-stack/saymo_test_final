import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import '../../../../core/providers/period_provider.dart';

class HistorySection extends StatelessWidget {
  final List<SymptomLog> history;
  final Function(int index)? onDelete;
  final Function(int index)? onEdit;

  const HistorySection({
    super.key,
    required this.history,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 10),
          child: Row(
            children: [
              const Text(
                '📋 تاریخچه',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444444),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${history.length} ثبت',
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(history.length, (i) {
          final log = history[i];
          return _buildHistoryItem(context, log, i);
        }),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, SymptomLog log, int index) {
    // 🔥 همه یه رنگ: صورتی
    const accentColor = AppColors.primary;

    return Dismissible(
      key: Key('history_${log.date}_$index'),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete?.call(index),
      child: GestureDetector(
        onTap: () => onEdit?.call(index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── ردیف بالا ───
              Row(
                children: [
                  // روز سیکل
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'روز ${log.day}',
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 11,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // مود
                  Text(log.mood, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  // 🔥 دایره‌های میزان درد (۱ تا ۵)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (j) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Icon(
                          j < log.pain ? Icons.circle : Icons.circle_outlined,
                          size: 8,
                          color:
                              j < log.pain ? accentColor : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // تاریخ
                  Text(
                    '${log.date.day} ${_monthName(log.date.month)}',
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_left,
                        size: 16, color: Colors.grey.shade300),
                  ],
                ],
              ),

              // ─── علائم ───
              if (log.symptoms.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: log.symptoms.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 10,
                          color: Color(0xFF666666),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // ─── یادداشت ───
              if (log.note != null && log.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '💬 ${log.note!}',
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 11,
                    color: Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('📝', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          const Text(
            'هنوز هیچ علامتی ثبت نشده',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'با دکمه + حال امروزت رو ثبت کن ✨',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند'
    ];
    return months[month];
  }
}
