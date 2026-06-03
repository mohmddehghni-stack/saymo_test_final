import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';

class RegisterStep1Page extends StatefulWidget {
  const RegisterStep1Page({super.key});

  @override
  State<RegisterStep1Page> createState() => _RegisterStep1PageState();
}

class _RegisterStep1PageState extends State<RegisterStep1Page>
    with SingleTickerProviderStateMixin {
  final _displayController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayFocus = FocusNode();
  final _usernameFocus = FocusNode();

  late AnimationController _bounceAnim;
  late Animation<double> _bounceScale;

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
      body: SafeArea(
        child: Stack(
          children: [
            // 🔥 پس‌زمینه تزئینی
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryDark.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 🔥 محتوای اصلی
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: size.height * 0.06,
                left: 28,
                right: 28,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // 🔥 کارت بالا: نام نمایشی
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _bounceScale.value,
                      child: child,
                    ),
                    child: _buildCard(
                      emoji: '💕',
                      title: 'عشقت چی صدات می‌کنه؟',
                      subtitle: 'یه اسم قشنگ انتخاب کن',
                      child: TextField(
                        controller: _displayController,
                        focusNode: _displayFocus,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                        decoration: InputDecoration(
                          hintText: 'مثلاً: عزیزم، ممد، سارا',
                          hintStyle: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
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
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 کارت پایین: نام کاربری
                  if (_showUsername)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      builder: (_, v, child) => Opacity(
                        opacity: v,
                        child: Transform.scale(scale: v, child: child),
                      ),
                      child: _buildCard(
                        emoji: '👤',
                        title: 'یه اسم کاربری انتخاب کن',
                        subtitle: 'فقط انگلیسی و اعداد',
                        child: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              focusNode: _usernameFocus,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: 2,
                              ),
                              decoration: InputDecoration(
                                hintText: 'username',
                                hintStyle: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 15,
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            if (_usernameError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _usernameError!,
                                  style: const TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 12,
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
                                    fontSize: 12,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // 🔥 انتخاب جنسیت
                  _buildGenderChips(p),

                  const SizedBox(height: 32),

                  // 🔥 دکمه ادامه
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              valid ? AppColors.primary : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: valid ? 4 : 0,
                          shadowColor: AppColors.primary.withOpacity(0.4),
                        ),
                        onPressed: valid ? () => p.nextStep() : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'بعدی',
                              style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color:
                                  valid ? Colors.white : Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Vazir',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildGenderChips(RegistrationProvider p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => p.setGender('male'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: p.gender == 'male' ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: p.gender == 'male'
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ]
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
            ),
            child: Row(
              children: [
                const Text('👦', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('پسر',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.gender == 'male' ? Colors.white : Colors.black54,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => p.setGender('female'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: p.gender == 'female' ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: p.gender == 'female'
                  ? [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ]
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2)),
                    ],
            ),
            child: Row(
              children: [
                const Text('👧', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('دختر',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          p.gender == 'female' ? Colors.white : Colors.black54,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
