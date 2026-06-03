import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String? email;

  const OtpPage({
    super.key,
    required this.phone,
    this.email,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  int _secondsLeft = 60;
  bool _canResend = false;

  late AnimationController _pulseAnim;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_secondsLeft > 0 && mounted) {
        setState(() => _secondsLeft--);
        _startTimer();
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verifyCode(String code) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/register-info', arguments: {
          'phone': widget.phone,
          'email': widget.email,
        });
      } else {
        _showError('کد اشتباهه! دوباره سعی کن 😕');
      }
    } catch (e) {
      _showError('خطا در اتصال به سرور');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _startTimer();

    try {
      await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': widget.phone}),
      );
      _showSuccess('کد دوباره ارسال شد 📩');
    } catch (e) {
      _showError('خطا در ارسال مجدد');
    }
  }

  void _showError(String msg) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 🔥 آیکون پالس‌دار
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseScale.value,
                    child: child,
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🔐', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 عنوان
                const Text(
                  'کد تایید',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔥 توضیح
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    'کد ۴ رقمی به ${widget.phone} پیامک شد',
                    style: const TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: Color(0xFF8E6E73),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // 🔥 باکس‌های OTP
                _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      )
                    : Pinput(
                        length: 4,
                        mainAxisAlignment: MainAxisAlignment.center,
                        defaultPinTheme: PinTheme(
                          width: 64,
                          height: 64,
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                            color: Color(0xFF1A1A2E),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 64,
                          height: 64,
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                            color: AppColors.primary,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 64,
                          height: 64,
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Vazir',
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onCompleted: _verifyCode,
                      ),

                const SizedBox(height: 36),

                // 🔥 ارسال مجدد
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _canResend
                      ? GestureDetector(
                          key: const ValueKey('resend'),
                          onTap: _resendCode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ارسال مجدد کد',
                                  style: TextStyle(
                                    fontFamily: 'Vazir',
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('timer'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ارسال مجدد تا $_secondsLeft ثانیه',
                                style: const TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
