import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'dart:math' as math;

class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page>
    with TickerProviderStateMixin {
  final _displayController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayFocus = FocusNode();
  final _usernameFocus = FocusNode();

  late AnimationController _rotateController;

  String? _usernameError;
  bool _isChecking = false;
  bool _showUsername = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<RegistrationProvider>();
    _displayController.text = p.displayName;
    _usernameController.text = p.username;

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    if (p.displayName.length >= 3) {
      _showUsername = true;
    }
  }

  void _onUsernameChanged(String v) {
    final filtered = v.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '').toLowerCase();
    if (filtered != v) {
      _usernameController.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
    context.read<RegistrationProvider>().setUsername(filtered);
    if (filtered.length >= 3) _checkUsername(filtered);
  }

  Future<void> _checkUsername(String u) async {
    setState(() => _isChecking = true);
    try {
      final available = await ApiService.isUsernameAvailable(u);
      if (mounted)
        setState(() {
          _usernameError = available ? null : 'قبلاً گرفته شده 😕';
          _isChecking = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    _usernameController.dispose();
    _displayFocus.dispose();
    _usernameFocus.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegistrationProvider>();
    final size = MediaQuery.of(context).size;
    final valid = p.displayName.length >= 3 &&
        _usernameError == null &&
        p.username.length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      body: Stack(
        children: [
          Container(
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
          ),
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
                      const Color(0xffFF6FAE).withOpacity(0.3),
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
                      const Color(0xffB57BFF).withOpacity(0.25),
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
                        color: const Color(0xffB57BFF).withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 8 + rng.nextDouble() * 14,
                    color: const Color(0xffFF6FAE),
                  ),
                ),
              ),
            );
          }),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: size.height * 0.1,
                left: 28,
                right: 28,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // عنوان مستقیم، بدون دایره ستاره
                  const Text(
                    'اسم نمایشی تو چیه؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'چطور دوست داری صدات کنیم؟ (حداقل ۳ حرف)',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: Color(0xFF8E8E98),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // کارت نام نمایشی
                  _buildGlassCard(
                    child: TextField(
                      controller: _displayController,
                      focusNode: _displayFocus,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                      decoration: InputDecoration(
                        hintText: 'مثلاً سارا، علی، ممد',
                        hintStyle: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                      ),
                      onChanged: (v) {
                        p.setDisplayName(v);
                        if (v.length >= 3) {
                          if (!_showUsername) {
                            setState(() => _showUsername = true);
                          }
                        } else {
                          if (_showUsername) {
                            setState(() => _showUsername = false);
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: _showUsername
                        ? Column(
                            children: [
                              const Text(
                                'یه اسم کاربری خاص',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'فقط انگلیسی و اعداد',
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 14,
                                  color: Color(0xFF8E8E98),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildGlassCard(
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _usernameController,
                                      focusNode: _usernameFocus,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A2E),
                                        letterSpacing: 2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'username',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 14,
                                          color: Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 16),
                                      ),
                                      onChanged: _onUsernameChanged,
                                      onSubmitted: (_) {
                                        if (valid) p.nextStep();
                                      },
                                    ),
                                    if (_isChecking)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xffB57BFF)),
                                        ),
                                      ),
                                    if (_usernameError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _usernameError!,
                                          style: const TextStyle(
                                            fontFamily: 'Vazir',
                                            fontSize: 13,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    if (p.username.length >= 3 &&
                                        _usernameError == null)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          '✅ قابل استفاده‌ست',
                                          style: TextStyle(
                                            fontFamily: 'Vazir',
                                            fontSize: 13,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 40),

                  _buildGenderPills(p),

                  const SizedBox(height: 44),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.9, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: GestureDetector(
                      onTap: valid ? () => p.nextStep() : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: valid
                                ? [
                                    const Color(0xffFF6FAE),
                                    const Color(0xffB57BFF)
                                  ]
                                : [Colors.grey.shade400, Colors.grey.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: valid
                              ? [
                                  BoxShadow(
                                    color: const Color(0xffB57BFF)
                                        .withOpacity(0.7),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  )
                                ]
                              : [],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            color: const Color(0xffB57BFF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xffFF6FAE).withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGenderPills(RegistrationProvider p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => p.setGender('male'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: p.gender == 'male'
                  ? const LinearGradient(
                      colors: [Color(0xffFF6FAE), Color(0xffB57BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F5F5)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: p.gender == 'male'
                    ? Colors.transparent
                    : const Color(0xffB57BFF).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: p.gender == 'male'
                  ? [
                      BoxShadow(
                        color: const Color(0xffFF6FAE).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.male_rounded,
                  size: 28,
                  color: p.gender == 'male'
                      ? Colors.white
                      : const Color(0xffB57BFF),
                ),
                const SizedBox(width: 8),
                Text(
                  'پسر',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.gender == 'male' ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => p.setGender('female'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: p.gender == 'female'
                  ? const LinearGradient(
                      colors: [Color(0xffFF6FAE), Color(0xffB57BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F5F5)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: p.gender == 'female'
                    ? Colors.transparent
                    : const Color(0xffB57BFF).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: p.gender == 'female'
                  ? [
                      BoxShadow(
                        color: const Color(0xffFF6FAE).withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.female_rounded,
                  size: 28,
                  color: p.gender == 'female'
                      ? Colors.white
                      : const Color(0xffB57BFF),
                ),
                const SizedBox(width: 8),
                Text(
                  'دختر',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: p.gender == 'female' ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
