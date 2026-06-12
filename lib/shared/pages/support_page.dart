import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _tickets = [
    {
      'title': 'مشکل در ثبت نام',
      'status': 'پاسخ داده شد',
      'date': '۱۴۰۴/۰۲/۱۰',
      'color': Colors.green,
    },
    {
      'title': 'سوال درباره اشتراک VIP',
      'status': 'در انتظار پاسخ',
      'date': '۱۴۰۴/۰۲/۱۲',
      'color': Colors.orange,
    },
  ];

  void _submitTicket() {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لطفاً همه فیلدها رو پر کن',
            style: TextStyle(fontFamily: 'Vazir'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _tickets.insert(0, {
        'title': _titleController.text.trim(),
        'status': 'در انتظار پاسخ',
        'date': _getCurrentDate(),
        'color': Colors.orange,
      });
      _titleController.clear();
      _messageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ تیکت با موفقیت ثبت شد!',
          style: TextStyle(fontFamily: 'Vazir'),
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color scaffoldBg =
        appTheme?.surfaceBackground ?? const Color(0xFFF5F0E8);
    final Color cardBg = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF3E2723);
    final Color hintColor = appTheme?.textHint ?? Colors.grey;
    final Color inputBg =
        isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F0E8);

    return Scaffold(
      backgroundColor: scaffoldBg, // 👈 پس‌زمینه کل صفحه
      appBar: AppBar(
        title: const Text(
          'پشتیبانی',
          style: TextStyle(fontFamily: 'Vazir', fontSize: 18),
        ),
        backgroundColor: AppColors.primaryDark, // رنگ برند ثابت می‌ماند
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // فرم تیکت جدید
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg, // 👈 کارت سفید/تیره
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 تیکت جدید',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor, // 👈
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontFamily: 'Vazir', fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'عنوان تیکت',
                    hintStyle: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      color: hintColor, // 👈
                    ),
                    filled: true,
                    fillColor: inputBg, // 👈
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _messageController,
                  textDirection: TextDirection.rtl,
                  maxLines: 4,
                  style: TextStyle(
                      fontFamily: 'Vazir', fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'توضیح مشکل...',
                    hintStyle: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      color: hintColor, // 👈
                    ),
                    filled: true,
                    fillColor: inputBg, // 👈
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _submitTicket,
                    child: const Text(
                      'ارسال تیکت 📨',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // لیست تیکت‌های قبلی
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.history, color: textColor, size: 18), // 👈
                const SizedBox(width: 6),
                Text(
                  'تیکت‌های قبلی',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor, // 👈
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                final ticket = _tickets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg, // 👈
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ticket['color'] as Color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor, // 👈
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  ticket['status'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 11,
                                    color: ticket['color'] as Color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  ticket['date'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 11,
                                    color: hintColor, // 👈
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
