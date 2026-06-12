import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/features/auth/pages/register_new_page.dart';
import 'package:flutter_application_1/features/home/pages/home_page.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _cardController;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    // انیمیشن ورود کارت
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardScaleAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    // بعد از یه تأخیر کوتاه، کارت ظاهر بشه
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    _cardController.dispose();
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
    // (منطق لاگین بدون تغییر)
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

        final appProvider = context.read<AppProvider>();
        final userId = response['user']['id'].toString();
        appProvider.setUserId(userId);

        final gender = response['user']['gender']?.toString() ?? 'female';
        appProvider.setGender(gender);
        appProvider.setUsername(response['user']['username']);

        try {
          final profileResponse = await ApiService.getProfile();
          print('🔥 FULL profile response: $profileResponse');

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

            if (profileResponse['user']?['avatar_url'] != null) {
              appProvider.setAvatarUrl(profileResponse['user']['avatar_url']);
            }

            if (profileResponse['partner']?['avatar_url'] != null) {
              appProvider.setPartnerAvatarUrl(
                  profileResponse['partner']['avatar_url']);
            }
          } else {
            appProvider.resetConnection();
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
      backgroundColor: const Color(0xFFFDFBFB),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: size.height,
          child: Stack(
            children: [
              // دایره گرادینتی پس‌زمینه
              Positioned(
                top: -size.height * 0.15,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width * 1.4,
                  height: size.width * 1.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xffFF6FAE).withOpacity(0.2),
                        const Color(0xffB57BFF).withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // آواتار با حاشیهٔ گرادینتی (جایگزین لوگو)
                      ScaleTransition(
                        scale: _cardScaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xffFF6FAE), Color(0xffB57BFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffFF6FAE).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3), // حاشیهٔ داخلی
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xffB57BFF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // کارت سفید با انیمیشن ورود
                      ScaleTransition(
                        scale: _cardScaleAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 36),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xffB57BFF).withOpacity(0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ورود',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Vazir',
                                  color: Color(0xffFF6FAE),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 50,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xffFF6FAE),
                                      Color(0xffB57BFF)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // فیلدها
                              _label('نام کاربری، ایمیل یا شماره تلفن'),
                              const SizedBox(height: 6),
                              _input(
                                controller: loginController,
                                hint: 'نام کاربری، ایمیل یا شماره تلفن',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 14),
                              _label('رمز عبور'),
                              const SizedBox(height: 6),
                              _input(
                                controller: passwordController,
                                hint: '********',
                                icon: Icons.lock,
                                isPassword: true,
                              ),
                              const SizedBox(height: 28),

                              // دکمه ورود
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xffFF6FAE),
                                        Color(0xffB57BFF)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffFF6FAE)
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'ورود',
                                            style: TextStyle(
                                              fontFamily: 'Vazir',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // لینک ثبت‌نام
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterNewPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'حساب کاربری ندارین؟ ثبت نام',
                                  style: TextStyle(
                                    color: Color(0xffB57BFF),
                                    fontFamily: 'Vazir',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // دکمه فراموشی رمز عبور
                              TextButton(
                                onPressed: () {
                                  _showMessage(
                                    'بخش بازیابی رمز در دست ساخت است 🙏',
                                    isError: false,
                                  );
                                },
                                child: const Text(
                                  'رمزت رو فراموش کردی؟',
                                  style: TextStyle(
                                    color: Color(0xffB57BFF),
                                    fontFamily: 'Vazir',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'Vazir',
            color: Color(0xff444444),
          )),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        obscureText: isPassword,
        style: const TextStyle(fontFamily: 'Vazir'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Vazir', fontSize: 13, color: Colors.black45),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Container(width: 1.5, height: 22, color: Colors.black12),
            ],
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
