import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/features/auth/widgets/chat_bubble.dart';
import 'package:flutter_application_1/features/auth/widgets/typing_indicator.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class RegisterStep3Page extends StatefulWidget {
  const RegisterStep3Page({super.key});

  @override
  State<RegisterStep3Page> createState() => _RegisterStep3PageState();
}

class _RegisterStep3PageState extends State<RegisterStep3Page>
    with SingleTickerProviderStateMixin {
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _confirmPassword = '';

  late AnimationController _emojiAnim;
  late Animation<double> _emojiScale;

  bool _showTyping = true;
  bool _showMessage1 = false;
  bool _showMessage2 = false;
  bool _showPasswordField = false;
  bool _showConfirmField = false;
  bool _showButtons = false;
  bool _showStrengthBar = false;
  bool _isLoading = false;

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

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _emojiAnim.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _showTyping = true);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted)
      setState(() {
        _showTyping = false;
        _showMessage1 = true;
      });

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showMessage2 = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted)
      setState(() {
        _showPasswordField = true;
        _showButtons = true;
      });
    _focusPassword();
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
    if (val.length >= 6 && !_showConfirmField) {
      setState(() => _showConfirmField = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confirmFocus.requestFocus();
      });
    }
    if (val.length >= 2 && !_showStrengthBar) {
      setState(() => _showStrengthBar = true);
    }
  }

  String _getStrengthLabel(String password) {
    if (password.length < 6) return 'ضعیف';
    if (password.length < 8) return 'متوسط';
    if (RegExp(r'(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) return 'قوی';
    return 'خوب';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          // ===== ایموجی =====
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
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5)
                    ],
                  ),
                  child: const Center(
                      child: Text('🔒', style: TextStyle(fontSize: 45))),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          if (_showTyping) const TypingIndicator(),

          if (_showMessage1)
            const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: ChatBubble(
                    text: 'یه رمز برای خونه‌مون انتخاب کن 🔐', isUser: false)),
          if (_showMessage2)
            const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ChatBubble(
                    text: 'حداقل ۶ کاراکتر.\nمی‌تونی حروف و عدد ترکیب کنی.',
                    isUser: false)),

          const SizedBox(height: 20),

          // فیلد رمز
          if (_showPasswordField)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showPasswordField ? 1.0 : 0.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 500),
                offset: _showPasswordField ? Offset.zero : const Offset(0, 0.3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        color: Color(0xFF2D2D2D)),
                    decoration: InputDecoration(
                      hintText: 'رمز عبور',
                      hintStyle: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Color(0xFFCCCCCC),
                          fontSize: 15),
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 16),
                          child: Icon(Icons.lock_outline_rounded,
                              color: AppColors.primary, size: 24)),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colors.grey.shade400,
                            size: 22),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                    onChanged: _onPasswordChanged,
                  ),
                ),
              ),
            ),

          // نشانگر قدرت رمز
          if (_showStrengthBar && provider.password.isNotEmpty) ...[
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(strengthColor)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(strengthLabel,
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: strengthColor)),
                ],
              ),
            ),
          ],

          // فیلد تکرار رمز
          if (_showConfirmField) ...[
            const SizedBox(height: 16),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showConfirmField ? 1.0 : 0.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 500),
                offset: _showConfirmField ? Offset.zero : const Offset(0, 0.3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: _confirmPassword.isEmpty
                              ? AppColors.primary.withOpacity(0.05)
                              : _confirmPassword == provider.password
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8))
                    ],
                    border: _confirmPassword.isEmpty
                        ? null
                        : Border.all(
                            color: _confirmPassword == provider.password
                                ? Colors.green.withOpacity(0.4)
                                : Colors.red.withOpacity(0.4),
                            width: 1.5),
                  ),
                  child: TextField(
                    controller: _confirmController,
                    focusNode: _confirmFocus,
                    obscureText: _obscureConfirm,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        color: Color(0xFF2D2D2D)),
                    decoration: InputDecoration(
                      hintText: 'تکرار رمز عبور',
                      hintStyle: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Color(0xFFCCCCCC),
                          fontSize: 15),
                      prefixIcon: Icon(
                          _confirmPassword.isEmpty
                              ? Icons.lock_outline_rounded
                              : _confirmPassword == provider.password
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                          color: _confirmPassword.isEmpty
                              ? AppColors.primary
                              : _confirmPassword == provider.password
                                  ? Colors.green
                                  : Colors.red,
                          size: 24),
                      suffixIcon: IconButton(
                          icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: Colors.grey.shade400,
                              size: 22),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                    onChanged: (val) => setState(() => _confirmPassword = val),
                    onSubmitted: (_) {
                      if (passwordsMatch) provider.nextStep();
                    },
                  ),
                ),
              ),
            ),
          ],

          if (_confirmPassword.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ChatBubble(
                  text: _confirmPassword == provider.password
                      ? 'آفرین! رمزها یکسان هستن ✅'
                      : 'هنوز یکسان نشدن... دوباره چک کن 😕',
                  isUser: false),
            ),

          const SizedBox(height: 24),

          // دکمه‌ها
          if (_showButtons)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showButtons ? 1.0 : 0.0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 500),
                offset: _showButtons ? Offset.zero : const Offset(0, 0.3),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.previousStep(),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2))),
                          child: const Center(
                              child: Icon(Icons.arrow_back_rounded,
                                  color: AppColors.primary, size: 24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: passwordsMatch
                              ? const LinearGradient(colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark
                                ])
                              : const LinearGradient(colors: [
                                  Color(0xFFEEEEEE),
                                  Color(0xFFE0E0E0)
                                ]),
                          boxShadow: passwordsMatch
                              ? [
                                  BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8))
                                ]
                              : [],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: passwordsMatch
                              ? () async {
                                  setState(() => _isLoading = true);
                                  try {
                                    print(
                                        '📝 Registering: ${provider.displayName}, ${provider.phone}, ${provider.password}');
                                    final response = await ApiService.register(
                                      provider.displayName,
                                      provider.username,
                                      provider.phone,
                                      provider.password,
                                      provider
                                          .gender, // 👈 'male' رو با provider.gender جایگزین کن
                                    );
                                    print('📥 Response: $response');

                                    if (response['token'] != null) {
                                      ApiService.setToken(response['token']);
                                      provider.setUserId(response['user']
                                              ['public_id'] ??
                                          response['user']['id']
                                              .toString()
                                              .padLeft(8, '0'));

                                      // 🔥 اینو اضافه کن: gender رو به AppProvider بفرست
                                      final appProvider =
                                          context.read<AppProvider>();
                                      appProvider.setUserId(
                                          response['user']['id'].toString());
                                      appProvider.setGender(provider
                                          .gender); // 🔥 از RegistrationProvider بگیر

                                      provider.nextStep();
                                    } else {
                                      _showError(response['error'] ??
                                          'خطا در ثبت‌نام');
                                    }
                                  } catch (e) {
                                    print('❌ Catch error: $e');
                                    _showError('خطا در اتصال به سرور');
                                  } finally {
                                    if (mounted)
                                      setState(() => _isLoading = false);
                                  }
                                }
                              : null,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('ادامه',
                                        style: TextStyle(
                                            fontFamily: 'Vazir',
                                            fontSize: 18,
                                            color: passwordsMatch
                                                ? Colors.white
                                                : Colors.grey.shade500,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded,
                                        color: passwordsMatch
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                        size: 22),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
