import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'dart:math' as math;

class RegisterStep3Page extends StatefulWidget {
  const RegisterStep3Page({super.key});

  @override
  State<RegisterStep3Page> createState() => _RegisterStep3PageState();
}

class _RegisterStep3PageState extends State<RegisterStep3Page>
    with TickerProviderStateMixin {
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _confirmPassword = '';

  late AnimationController _emojiAnim;
  late Animation<double> _emojiScale;
  late AnimationController _pageAnim;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUp;
  late AnimationController _rotateController;

  bool _showContent = false;
  bool _showConfirmField = false;
  bool _showStrengthBar = false;
  bool _isLoading = false;

  static const Color primaryPink = Color(0xFFFF6FAE);
  static const Color primaryPurple = Color(0xFFB57BFF);
  static const Color darkText = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegistrationProvider>();
    _passwordController = TextEditingController(text: provider.password);
    _confirmController = TextEditingController();

    _emojiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _emojiScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _emojiAnim, curve: Curves.elasticOut),
    );

    _pageAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageAnim, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageAnim, curve: Curves.easeOutCubic),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pageAnim.forward();

    // تأخیر کوتاه برای لود محتوا
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _emojiAnim.forward();
        setState(() => _showContent = true);
        _focusPassword();
      }
    });
  }

  void _showError(String message) {
    String userMessage;
    if (message.contains('همه فیلدها')) {
      userMessage = 'لطفاً همه فیلدها رو پر کن 😊';
    } else if (message.contains('شماره موبایل')) {
      userMessage = 'شماره موبایل معتبر نیست! با ۰۹ شروع بشه 📱';
    } else if (message.contains('شماره') && message.contains('قبلاً')) {
      userMessage = 'این شماره قبلاً ثبت شده! ورود کن 😍';
    } else if (message.contains('نام کاربری') && message.contains('قبلاً')) {
      userMessage = 'این نام کاربری قبلاً ثبت شده! یه اسم دیگه انتخاب کن 😊';
    } else if (message.contains('رمز')) {
      userMessage = 'رمز عبور باید حداقل ۶ کاراکتر باشه 🔐';
    } else if (message.contains('جنسیت')) {
      userMessage = 'لطفاً جنسیت رو انتخاب کن 👦👧';
    } else {
      userMessage = 'یه مشکلی پیش اومد! دوباره امتحان کن 🤗';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _focusPassword() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordFocus.requestFocus();
    });
  }

  void _onPasswordChanged(String val) {
    context.read<RegistrationProvider>().setPassword(val);
    // کنترل نمایش فیلد تأیید – بدون فوکوس خودکار
    if (val.length >= 6 && !_showConfirmField) {
      setState(() => _showConfirmField = true);
      // فوکوس خودکار حذف شده – کاربر باید دستی بزنه
    } else if (val.length < 6 && _showConfirmField) {
      setState(() => _showConfirmField = false);
    }
    if (val.length >= 2 && !_showStrengthBar) {
      setState(() => _showStrengthBar = true);
    }
  }

  int _calculatePasswordScore(String password) {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score; // بین ۰ تا ۷
  }

  String _getStrengthLabel(String password) {
    final score = _calculatePasswordScore(password);
    if (score >= 6) return 'قوی';
    if (score >= 4) return 'خوب';
    if (score >= 2) return 'متوسط';
    return 'ضعیف';
  }

  Color _getStrengthColor(String label) {
    switch (label) {
      case 'ضعیف':
        return Colors.red.shade400;
      case 'متوسط':
        return Colors.orange;
      case 'خوب':
        return Colors.amber.shade700;
      case 'قوی':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  double _getStrengthValue(String label) {
    switch (label) {
      case 'ضعیف':
        return 0.25;
      case 'متوسط':
        return 0.5;
      case 'خوب':
        return 0.75;
      case 'قوی':
        return 1.0;
      default:
        return 0.0;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _emojiAnim.dispose();
    _pageAnim.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final strengthLabel = _getStrengthLabel(provider.password);
    final strengthColor = _getStrengthColor(strengthLabel);
    final strengthValue = _getStrengthValue(strengthLabel);
    final passwordsMatch = _confirmPassword.isNotEmpty &&
        _confirmPassword == provider.password &&
        provider.password.length >= 6;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFE0EC),
              Color(0xffF2E8FF),
              Color(0xffE0F0FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: RotationTransition(
                turns: _rotateController,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryPink.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: RotationTransition(
                turns: _rotateController,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryPurple.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            ...List.generate(10, (index) {
              final rng = math.Random(index);
              return Positioned(
                top: rng.nextDouble() * size.height * 0.7,
                left: rng.nextDouble() * size.width * 0.9,
                child: Opacity(
                  opacity: 0.15 + rng.nextDouble() * 0.2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 8 + rng.nextDouble() * 14,
                      color: primaryPink,
                    ),
                  ),
                ),
              );
            }),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        AnimatedBuilder(
                          animation: _emojiAnim,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _emojiScale.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [primaryPink, primaryPurple],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryPink.withOpacity(0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('🔒',
                                      style: TextStyle(fontSize: 45)),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'یه رمز امن انتخاب کن',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'حداقل ۶ کاراکتر، می‌تونی حروف و عدد ترکیب کنی',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E98),
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (_showContent)
                          _buildGlassCard(
                            child: TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: _obscurePassword,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 18,
                                color: darkText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'رمز عبور',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 15,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 12, right: 16),
                                  child: Icon(Icons.lock_outline_rounded,
                                      color: primaryPink, size: 24),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.grey.shade400,
                                    size: 22,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                              ),
                              onChanged: _onPasswordChanged,
                            ),
                          ),
                        if (_showStrengthBar &&
                            provider.password.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _showStrengthBar ? 1.0 : 0.0,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: strengthValue,
                                      minHeight: 4,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          strengthColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  strengthLabel,
                                  style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: strengthColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_showConfirmField) ...[
                          const SizedBox(height: 16),
                          _buildGlassCard(
                            borderColor: _confirmPassword.isEmpty
                                ? null
                                : _confirmPassword == provider.password
                                    ? Colors.green
                                    : Colors.red,
                            child: TextField(
                              controller: _confirmController,
                              focusNode: _confirmFocus,
                              obscureText: _obscureConfirm,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 18,
                                color: darkText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'تکرار رمز عبور',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Vazir',
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  _confirmPassword.isEmpty
                                      ? Icons.lock_outline_rounded
                                      : _confirmPassword == provider.password
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                  color: _confirmPassword.isEmpty
                                      ? primaryPink
                                      : _confirmPassword == provider.password
                                          ? Colors.green
                                          : Colors.red,
                                  size: 24,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.grey.shade400,
                                    size: 22,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                              ),
                              onChanged: (val) =>
                                  setState(() => _confirmPassword = val),
                              onSubmitted: (_) {
                                if (passwordsMatch) provider.nextStep();
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        if (_showContent)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => provider.previousStep(),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: primaryPink.withOpacity(0.15),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_back_rounded,
                                        color: primaryPink,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: passwordsMatch
                                        ? const LinearGradient(
                                            colors: [
                                              primaryPink,
                                              primaryPurple
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : LinearGradient(
                                            colors: [
                                              const Color(0xFFEEEEEE),
                                              const Color(0xFFE8E8E8),
                                            ],
                                          ),
                                    boxShadow: passwordsMatch
                                        ? [
                                            BoxShadow(
                                              color:
                                                  primaryPink.withOpacity(0.35),
                                              blurRadius: 22,
                                              offset: const Offset(0, 8),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: passwordsMatch
                                          ? () async {
                                              setState(() => _isLoading = true);
                                              try {
                                                final response =
                                                    await ApiService.register(
                                                  provider.displayName,
                                                  provider.username,
                                                  provider.phone,
                                                  provider.password,
                                                  provider.gender,
                                                );

                                                if (response['token'] != null) {
                                                  ApiService.setToken(
                                                      response['token']);
                                                  provider.setUserId(
                                                    response['user']
                                                            ['public_id'] ??
                                                        response['user']['id']
                                                            .toString()
                                                            .padLeft(8, '0'),
                                                  );

                                                  final appProvider = context
                                                      .read<AppProvider>();
                                                  appProvider.setUserId(
                                                    response['user']['id']
                                                        .toString(),
                                                  );
                                                  appProvider.setGender(
                                                      provider.gender);

                                                  provider.nextStep();
                                                } else {
                                                  _showError(
                                                    response['error'] ??
                                                        'خطا در ثبت‌نام',
                                                  );
                                                }
                                              } catch (e) {
                                                _showError(
                                                    'خطا در اتصال به سرور');
                                              } finally {
                                                if (mounted)
                                                  setState(
                                                      () => _isLoading = false);
                                              }
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                      splashColor:
                                          Colors.white.withOpacity(0.3),
                                      highlightColor:
                                          Colors.white.withOpacity(0.15),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Row(
                                                  key: const ValueKey('text'),
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'ادامه',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: passwordsMatch
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFFAAAAAA),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: passwordsMatch
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFFAAAAAA),
                                                      size: 22,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepDot(isActive: false),
                            _buildStepConnector(),
                            _buildStepDot(isActive: false),
                            _buildStepConnector(),
                            _buildStepDot(isActive: true),
                            _buildStepConnector(),
                            _buildStepDot(isActive: false),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor != null
                ? borderColor.withOpacity(0.2)
                : primaryPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: primaryPink.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStepDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: isActive
            ? const LinearGradient(colors: [primaryPink, primaryPurple])
            : null,
        color: isActive ? null : const Color(0xFFDDDDDD),
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 16,
      height: 1.5,
      color: const Color(0xFFDDDDDD),
    );
  }
}
