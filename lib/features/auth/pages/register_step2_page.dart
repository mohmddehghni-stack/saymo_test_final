import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'dart:math' as math;

class RegisterStep2Page extends StatefulWidget {
  const RegisterStep2Page({super.key});

  @override
  State<RegisterStep2Page> createState() => _RegisterStep2PageState();
}

class _RegisterStep2PageState extends State<RegisterStep2Page>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  late AnimationController _pageAnim;
  late AnimationController _pulseAnim;
  late AnimationController _shakeAnim;
  late AnimationController _successAnim;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUp;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _shakeAnimation;
  late Animation<double> _successBounce;

  bool _isFocused = false;
  bool _isValid = false;
  bool _showSuccess = false;
  String? _phoneError;
  bool _isChecking = false;

  static const Color primaryPink = Color(0xFFFF6FAE);
  static const Color primaryPurple = Color(0xFFB57BFF);
  static const Color darkText = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegistrationProvider>();

    String initialPhone = '';
    if (provider.phone.isNotEmpty) {
      initialPhone = provider.phone;
    } else {
      initialPhone = '09';
    }
    _controller = TextEditingController(text: _formatPhone(initialPhone));

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

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut),
    );

    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.06, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeAnim);

    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });

    _pageAnim.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _focusNode.requestFocus();
      });
    });
  }

  String _formatPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length <= 4) return digits;
    if (digits.length <= 7)
      return '${digits.substring(0, 4)} ${digits.substring(4)}';
    if (digits.length <= 11)
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 11)}';
  }

  Future<void> _checkPhone(String val) async {
    String rawPhone = val.replaceAll(' ', '');

    if (rawPhone.isEmpty) {
      _controller.value = const TextEditingValue(
        text: '09',
        selection: TextSelection.collapsed(offset: 2),
      );
      context.read<RegistrationProvider>().setPhone('09');
      if (mounted) {
        setState(() {
          _isValid = false;
          _showSuccess = false;
          _phoneError = null;
        });
      }
      return;
    }

    if (!rawPhone.startsWith('0')) rawPhone = '0$rawPhone';
    if (rawPhone.startsWith('0') &&
        rawPhone.length >= 2 &&
        rawPhone[1] != '9') {
      rawPhone = '09${rawPhone.substring(2)}';
    }
    if (rawPhone == '0') rawPhone = '09';
    if (rawPhone.length > 11) rawPhone = rawPhone.substring(0, 11);

    final formatted = _formatPhone(rawPhone);
    if (formatted != val) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    context.read<RegistrationProvider>().setPhone(rawPhone);
    final isValid = rawPhone.startsWith('09') && rawPhone.length == 11;

    if (mounted) {
      setState(() {
        _isValid = isValid;
        _showSuccess = false;
      });
    }

    if (isValid) {
      setState(() => _isChecking = true);
      try {
        final available = await ApiService.isPhoneAvailable(rawPhone);
        if (mounted) {
          setState(() {
            _phoneError = available ? null : 'این شماره قبلاً ثبت شده 💔';
            _isChecking = false;
            if (available) {
              _showSuccess = true;
              _successAnim.forward(from: 0);
              HapticFeedback.lightImpact();
            }
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isChecking = false);
      }
    } else {
      setState(() => _phoneError = null);
    }
  }

  void _handleSubmit() {
    final provider = context.read<RegistrationProvider>();
    if (_isValid && _phoneError == null && !_isChecking) {
      HapticFeedback.mediumImpact();
      provider.nextStep();
    } else if (_phoneError != null) {
      _shakeAnim.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _pageAnim.dispose();
    _pulseAnim.dispose();
    _shakeAnim.dispose();
    _successAnim.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final phoneDigits = _controller.text.replaceAll(' ', '');
    final progressPercent = (phoneDigits.length / 11).clamp(0.0, 1.0);

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
              child: GestureDetector(
                onTap: () => _focusNode.unfocus(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideUp,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 28,
                        right: 28,
                        top: size.height * 0.06,
                        bottom: bottomInset + 32,
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        primaryPink.withOpacity(0.08),
                                        primaryPink.withOpacity(0.02),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        primaryPink.withOpacity(0.12),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [primaryPink, primaryPurple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryPink.withOpacity(0.3),
                                        blurRadius: 35,
                                        spreadRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: primaryPurple.withOpacity(0.15),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text('📱',
                                        style: TextStyle(fontSize: 42)),
                                  ),
                                ),
                                ...List.generate(4, (i) {
                                  final angles = [0.2, 0.4, 0.6, 0.8];
                                  return Positioned(
                                    top: 25 + (i * 15),
                                    right: 22 - (i * 7),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(
                                          milliseconds: 1500 + (i * 400)),
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity:
                                              (value * 0.5).clamp(0.0, 0.5),
                                          child: Transform.translate(
                                            offset: Offset(0, -6 * value),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 6 - (i * 0.8),
                                        height: 6 - (i * 0.8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryPink.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'شماره موبایلت رو بگو 💌',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 36),
                          AnimatedBuilder(
                            animation: _shakeAnim,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: _shakeAnimation.value,
                                child: child,
                              );
                            },
                            child: _buildGlassCard(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: darkText,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: '09__ ___ ____',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFFCCCCCC),
                                    fontSize: 18,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  hintTextDirection: TextDirection.ltr,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 10),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: _showSuccess
                                          ? TweenAnimationBuilder<double>(
                                              tween:
                                                  Tween(begin: 0.0, end: 1.0),
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.elasticOut,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: const Icon(
                                                    Icons.favorite_rounded,
                                                    key: ValueKey('heart'),
                                                    color: primaryPink,
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                            )
                                          : _isChecking
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: primaryPink,
                                                  ),
                                                )
                                              : Icon(
                                                  _isFocused
                                                      ? Icons
                                                          .phone_android_rounded
                                                      : Icons
                                                          .phone_android_outlined,
                                                  key: const ValueKey('phone'),
                                                  color: _isFocused
                                                      ? primaryPink
                                                      : const Color(0xFFBBBBBB),
                                                  size: 24,
                                                ),
                                    ),
                                  ),
                                  suffixIcon: _phoneError != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 14),
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.elasticOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.redAccent
                                                        .withOpacity(0.1),
                                                  ),
                                                  child: const Icon(
                                                    Icons.info_outline_rounded,
                                                    color: Colors.redAccent,
                                                    size: 18,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : _showSuccess
                                          ? const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 14),
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                color: Color(0xFF4CAF50),
                                                size: 24,
                                              ),
                                            )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                ),
                                onChanged: _checkPhone,
                                onSubmitted: (_) => _handleSubmit(),
                              ),
                            ),
                          ),
                          if (_phoneError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.sentiment_dissatisfied_rounded,
                                        color: Colors.redAccent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _phoneError!,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_phoneError == null && phoneDigits.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: LinearProgressIndicator(
                                      value: progressPercent,
                                      minHeight: 4,
                                      backgroundColor:
                                          primaryPink.withOpacity(0.08),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    progressPercent == 1.0
                                        ? 'عالیه! آماده ادامه‌ایم ✨'
                                        : '${(11 - phoneDigits.length)} رقم دیگه',
                                    style: TextStyle(
                                      color: progressPercent == 1.0
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF999999),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 36),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context
                                      .read<RegistrationProvider>()
                                      .previousStep(),
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
                                    gradient: _isValid && _phoneError == null
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
                                    boxShadow: _isValid && _phoneError == null
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
                                      onTap: (_isValid &&
                                              _phoneError == null &&
                                              !_isChecking)
                                          ? _handleSubmit
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
                                          child: _isChecking
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
                                                        color: _isValid &&
                                                                _phoneError ==
                                                                    null
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
                                                      color: _isValid &&
                                                              _phoneError ==
                                                                  null
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
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepDot(isActive: false),
                              _buildStepConnector(),
                              _buildStepDot(isActive: true),
                              _buildStepConnector(),
                              _buildStepDot(isActive: false),
                              _buildStepConnector(),
                              _buildStepDot(isActive: false),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.15),
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
