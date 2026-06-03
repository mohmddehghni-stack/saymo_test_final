import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

class ConnectBanner extends StatefulWidget {
  final VoidCallback onConnected;

  const ConnectBanner({super.key, required this.onConnected});

  @override
  State<ConnectBanner> createState() => _ConnectBannerState();
}

class _ConnectBannerState extends State<ConnectBanner> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final code = _controller.text.trim();
    if (code.length != 8) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.connectPartner(code);

      if (response['message'] != null) {
        widget.onConnected();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.favorite, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('وصل شدین! 💕', style: TextStyle(fontFamily: 'Vazir'))
            ]),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        setState(() => _errorMessage = response['error'] ?? 'خطا در اتصال');
      }
    } catch (e) {
      setState(() => _errorMessage = 'خطا در اتصال به سرور 📡');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.periodBackground,
            AppColors.primary.withOpacity(0.08)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('🔗', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          const Text(
            'کد دعوت عشقت رو وارد کن',
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 18,
                    letterSpacing: 4,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '12345678',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfacePrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _errorMessage,
                    errorStyle:
                        const TextStyle(fontFamily: 'Vazir', fontSize: 10),
                  ),
                  onChanged: (_) => setState(() => _errorMessage = null),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'وصل شو 💕',
                        style:
                            TextStyle(fontFamily: 'Vazir', color: Colors.white),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
