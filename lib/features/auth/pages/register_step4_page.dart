import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import 'dart:math' as math;
import 'package:flutter_application_1/features/auth/widgets/confetti_widget.dart';

class RegisterStep4Page extends StatefulWidget {
  const RegisterStep4Page({super.key});

  @override
  State<RegisterStep4Page> createState() => _RegisterStep4PageState();
}

class _RegisterStep4PageState extends State<RegisterStep4Page>
    with TickerProviderStateMixin {
  late TextEditingController _partnerIdController;
  final FocusNode _partnerFocus = FocusNode();
  bool _isConnecting = false;
  bool _showConfetti = false;

  late AnimationController _pageAnim;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUp;
  late AnimationController _rotateController;

  bool _showContent = false;

  static const Color primaryPink = Color(0xFFFF6FAE);
  static const Color primaryPurple = Color(0xFFB57BFF);
  static const Color darkText = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _partnerIdController = TextEditingController(
      text: context.read<RegistrationProvider>().partnerId,
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

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _showContent = true;
          _showConfetti = true;
        });
        // بعد از ۴ ثانیه افکت قطع بشه
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showConfetti = false);
        });
      }
    });
  }

  void _copyId(String id) {
    final englishId = id
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9');

    Clipboard.setData(ClipboardData(text: englishId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('آیدی کپی شد! 📋', style: TextStyle(fontFamily: 'Vazir'))
        ]),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _connectPartner() async {
    final id = _partnerIdController.text.trim();
    if (id.length != 8) return;

    setState(() => _isConnecting = true);

    try {
      final response = await ApiService.connectPartner(id);
      if (response['message'] != null) {
        context.read<RegistrationProvider>().setPartnerId(id);

        final partner = response['partner'];
        if (partner != null) {
          context.read<AppProvider>().connectPartner(
                partner['username'] ?? '',
                partnerId: partner['id']?.toString(),
                displayName: partner['displayName'],
                partnerGender: partner['gender'],
              );
        }

        _showSuccessDialog();
      } else {
        _showError(response['error'] ?? 'خطا در اتصال');
      }
    } catch (e) {
      _showError('خطا در اتصال به سرور');
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.favorite, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'وصل شدین! 💕',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'حالا می‌تونین از همه امکانات\nبا هم استفاده کنین 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    'بریم خونه 🏠',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Vazir')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _partnerIdController.dispose();
    _partnerFocus.dispose();
    _pageAnim.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final userId = provider.userId.isNotEmpty ? provider.userId : '25486123';
    final canConnect = _partnerIdController.text.trim().length == 8;
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
            ConfettiWidget(
              isPlaying: _showConfetti,
              child: SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideUp,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 100),
                          const Text(
                            '🎉 خوش اومدی به سایمو!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ثبت‌نامت کامل شد، حالا نوبت وصل شدنه',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E98),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_showContent) ...[
                            // کارت آیدی
                            _buildGlassCard(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryPink.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.fingerprint,
                                            size: 14, color: primaryPink),
                                        SizedBox(width: 6),
                                        Text(
                                          'آیدی دائمی تو',
                                          style: TextStyle(
                                            fontFamily: 'Vazir',
                                            fontSize: 12,
                                            color: primaryPink,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _formatId(userId),
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: primaryPink,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'این آیدی همیشه معتبره ✅',
                                    style: TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 11,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => _copyId(userId),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  primaryPink,
                                                  primaryPurple,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryPink
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.copy,
                                                    color: Colors.white,
                                                    size: 17),
                                                SizedBox(width: 8),
                                                Text(
                                                  'کپی آیدی',
                                                  style: TextStyle(
                                                    fontFamily: 'Vazir',
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration: BoxDecoration(
                                              color:
                                                  primaryPink.withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: primaryPink
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.share_rounded,
                                                    color: primaryPink,
                                                    size: 17),
                                                SizedBox(width: 8),
                                                Text(
                                                  'اشتراک',
                                                  style: TextStyle(
                                                    fontFamily: 'Vazir',
                                                    color: primaryPink,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'اگه آیدی هم‌نفست رو داری،\nبفرست تا وصل بشین 💕',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: darkText,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // فیلد آیدی پارتنر
                            _buildGlassCard(
                              child: TextField(
                                controller: _partnerIdController,
                                focusNode: _partnerFocus,
                                textAlign: TextAlign.left,
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.number,
                                maxLength: 8,
                                style: const TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 22,
                                  color: darkText,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 5,
                                ),
                                decoration: InputDecoration(
                                  hintText: '12345678',
                                  counterText: '',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Vazir',
                                    color: Color(0xFFCCCCCC),
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  prefixIcon: Icon(
                                    canConnect
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: canConnect
                                        ? primaryPink
                                        : Colors.grey.shade400,
                                    size: 24,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 18),
                                ),
                                onChanged: (val) => setState(() {}),
                                onSubmitted: (_) {
                                  if (canConnect) _connectPartner();
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (canConnect)
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [primaryPink, primaryPurple],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryPink.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    onPressed:
                                        _isConnecting ? null : _connectPartner,
                                    child: _isConnecting
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.link_rounded,
                                                  color: Colors.white,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'وصل شو 💕',
                                                style: TextStyle(
                                                  fontFamily: 'Vazir',
                                                  fontSize: 17,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            // خط یا
                            Row(children: [
                              Expanded(
                                child: Container(
                                    height: 1, color: Colors.grey.shade200),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('یا',
                                    style: TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 13,
                                        color: Colors.grey.shade400)),
                              ),
                              Expanded(
                                child: Container(
                                    height: 1, color: Colors.grey.shade200),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            // دکمه بعداً
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                  context, '/home'),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: primaryPink.withOpacity(0.2),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'بعداً انجام می‌دم',
                                      style: TextStyle(
                                        fontFamily: 'Vazir',
                                        fontSize: 14,
                                        color: darkText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded,
                                        color: darkText, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // نشانگر مرحله
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStepDot(isActive: false),
                                _buildStepConnector(),
                                _buildStepDot(isActive: false),
                                _buildStepConnector(),
                                _buildStepDot(isActive: false),
                                _buildStepConnector(),
                                _buildStepDot(isActive: true),
                              ],
                            ),
                          ],
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatId(String id) {
    if (id.length != 8) return id;
    return '${id.substring(0, 2)} ${id.substring(2, 4)} ${id.substring(4, 6)} ${id.substring(6, 8)}';
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
