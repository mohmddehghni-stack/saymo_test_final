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

  late AnimationController _bounceAnim;
  late Animation<double> _bounceScale;
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

    _bounceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _bounceScale = Tween(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _bounceAnim, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
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
    _bounceAnim.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RegistrationProvider>();
    final size = MediaQuery.of(context).size;
    final valid = p.displayName.length >= 2 &&
        _usernameError == null &&
        p.username.length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      body: Stack(
        children: [
          // پس‌زمینهٔ سه‌رنگ (بدون تغییر)
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

          // دایره‌های چرخان (حفظ شده)
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

          // ذرات ستاره‌ای به‌جای قلب
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
                top: size.height * 0.05,
                left: 28,
                right: 28,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // ستارهٔ جادویی به‌جای قلب
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _bounceScale.value,
                      child: child,
                    ),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xffFF6FAE).withOpacity(0.3),
                            const Color(0xffB57BFF).withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffB57BFF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 42,
                        color: Color(0xffB57BFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // عنوان جدید
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
                    'چطور دوست داری صدات کنیم؟',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 14,
                      color: Color(0xFF8E8E98),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // کارت شیشه‌ای نام نمایشی
                  _buildGlassCard(
                    child: Column(
                      children: [
                        TextField(
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
                            if (v.length >= 2 && !_showUsername) {
                              setState(() => _showUsername = true);
                              Future.delayed(const Duration(milliseconds: 400),
                                  () {
                                _usernameFocus.requestFocus();
                              });
                            }
                          },
                          onSubmitted: (_) => _usernameFocus.requestFocus(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // نام کاربری (بدون تغییر در ظاهر)
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

                  // انتخاب جنسیت (با آیکن‌های خنثی‌تر)
                  _buildGenderRings(p),

                  const SizedBox(height: 44),

                  // دکمه ادامه (بدون تغییر)
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

  Widget _buildGenderRings(RegistrationProvider p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => p.setGender('male'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: p.gender == 'male'
                  ? const LinearGradient(
                      colors: [Color(0xffFF6FAE), Color(0xffB57BFF)])
                  : const LinearGradient(
                      colors: [Colors.transparent, Colors.transparent]),
              boxShadow: p.gender == 'male'
                  ? [
                      BoxShadow(
                        color: const Color(0xffB57BFF).withOpacity(0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.male_rounded,
                    size: 48,
                    color: Color(0xffB57BFF),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'پسر',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: p.gender == 'male'
                          ? const Color(0xffFF6FAE)
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () => p.setGender('female'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: p.gender == 'female'
                  ? const LinearGradient(
                      colors: [Color(0xffFF6FAE), Color(0xffB57BFF)])
                  : const LinearGradient(
                      colors: [Colors.transparent, Colors.transparent]),
              boxShadow: p.gender == 'female'
                  ? [
                      BoxShadow(
                        color: const Color(0xffB57BFF).withOpacity(0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.female_rounded,
                    size: 48,
                    color: Color(0xffB57BFF),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'دختر',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: p.gender == 'female'
                          ? const Color(0xffFF6FAE)
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
