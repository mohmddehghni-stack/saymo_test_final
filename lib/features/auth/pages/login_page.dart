import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/features/auth/pages/register_new_page.dart';
import 'package:flutter_application_1/features/home/pages/home_page.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: isError ? Colors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _login() async {
    final login = loginController.text.trim();
    final password = passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      _showMessage('لطفاً همه فیلدها را پر کنید 😊');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(login, password);

      if (response['token'] != null) {
        ApiService.setToken(response['token']);

        // 👈 appProvider رو اینجا تعریف کن (بعد از setState)
        final appProvider = context.read<AppProvider>();

        // ذخیره userId
        // ذخیره userId
        final userId = response['user']['id'].toString();
        appProvider.setUserId(userId);

// 🔥 gender رو از response بگیر
        final gender = response['user']['gender']?.toString() ?? 'female';
        appProvider.setGender(gender);
        appProvider.setUsername(response['user']['username']);

        // پروفایل رو بگیر
        try {
          final profileResponse = await ApiService.getProfile();
          print('🔥 FULL profile response: $profileResponse');

          // 🔥 ذخیره coupleId (اگر وجود داشت)
          if (profileResponse['user']?['couple_id'] != null) {
            final coupleId = profileResponse['user']['couple_id'];
            appProvider.setCoupleId(coupleId);
            ApiService.setToken(response['token'], coupleId: coupleId);
          }

          if (profileResponse['partner'] != null) {
            appProvider.connectPartner(
              profileResponse['partner']['username'] ?? 'پارتنر',
              partnerId: profileResponse['partner']['id']?.toString(),
              displayName: profileResponse['partner']['display_name'],
              partnerGender: profileResponse['partner']['gender'],
            );

            // 🔥 آواتار خودم
            if (profileResponse['user']?['avatar_url'] != null) {
              appProvider.setAvatarUrl(profileResponse['user']['avatar_url']);
            }

            // 🔥 آواتار پارتنر
            if (profileResponse['partner']?['avatar_url'] != null) {
              appProvider.setPartnerAvatarUrl(
                  profileResponse['partner']['avatar_url']);
            }
          } else {
            appProvider.resetConnection();

            // 🔥 حتی اگه پارتنر نداره، آواتار خودش رو ست کن
            if (profileResponse['user']?['avatar_url'] != null) {
              appProvider.setAvatarUrl(profileResponse['user']['avatar_url']);
            }
          }
        } catch (_) {
          appProvider.resetConnection();
        }

        _showMessage('✅ ورود با موفقیت انجام شد');

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      } else {
        final error = response['error'] ?? 'خطا در ورود';
        if (error.contains('اشتباه')) {
          _showMessage('❌ نام کاربری یا رمز عبور اشتباهه', isError: true);
        } else if (error.contains('الزامی')) {
          _showMessage('لطفاً همه فیلدها را پر کنید 😊');
        } else {
          _showMessage(error, isError: true);
        }
      }
    } catch (e) {
      _showMessage('خطا در اتصال به سرور 📡', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFDFBFB),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.63,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Image.asset('assets/images/Group2.png',
                        fit: BoxFit.contain, width: double.infinity),
                  ),
                  Positioned(
                    bottom: 140,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('ورود',
                            style:
                                TextStyle(fontSize: 30, fontFamily: 'Vazir')),
                        const SizedBox(height: 6),
                        Container(
                            width: 70, height: 4, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    _label('نام کاربری، ایمیل یا شماره تلفن'),
                    const SizedBox(height: 6),
                    _input(
                        controller: loginController,
                        hint: 'نام کاربری، ایمیل یا شماره تلفن',
                        icon: Icons.person),
                    const SizedBox(height: 14),
                    _label('رمز عبور'),
                    const SizedBox(height: 6),
                    _input(
                        controller: passwordController,
                        hint: '********',
                        icon: Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('ورود',
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 17,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text('حساب کاربری ندارین؟ ثبت نام',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Vazir',
                              fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _label(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Vazir')),
    );
  }

  static Widget _input(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Vazir', fontSize: 12, color: Colors.black54),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Icon(icon),
              const SizedBox(width: 8),
              Container(width: 1.5, height: 22, color: Colors.black26),
            ],
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2)),
        ),
      ),
    );
  }
}
