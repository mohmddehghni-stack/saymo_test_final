import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/features/auth/widgets/chat_bubble.dart';
import 'package:flutter_application_1/features/auth/widgets/typing_indicator.dart';
import 'package:flutter_application_1/features/auth/widgets/confetti_widget.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class RegisterStep4Page extends StatefulWidget {
  const RegisterStep4Page({super.key});

  @override
  State<RegisterStep4Page> createState() => _RegisterStep4PageState();
}

class _RegisterStep4PageState extends State<RegisterStep4Page> {
  late TextEditingController _partnerIdController;
  final FocusNode _partnerFocus = FocusNode();
  bool _isConnecting = false;

  bool _showCongrats = false;
  bool _showEmoji = false;
  bool _showCard = false;
  bool _showTyping3 = false;
  bool _showInviteMessage = false;
  bool _showPartnerField = false;
  bool _showButtons = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _partnerIdController = TextEditingController(
        text: context.read<RegistrationProvider>().partnerId);
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted)
      setState(() {
        _showEmoji = true;
        _showCongrats = true;
        _showConfetti = true;
      });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showConfetti = false);
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _showCard = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _showTyping3 = true);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted)
      setState(() {
        _showTyping3 = false;
        _showInviteMessage = true;
      });

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted)
      setState(() {
        _showPartnerField = true;
        _showButtons = true;
      });
  }

  void _copyId(String id) {
    // تبدیل اعداد فارسی به انگلیسی
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
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark]),
                      shape: BoxShape.circle),
                  child: const Center(
                      child:
                          Icon(Icons.favorite, color: Colors.white, size: 40))),
              const SizedBox(height: 16),
              const Text('وصل شدین! 💕',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D))),
              const SizedBox(height: 8),
              const Text('حالا می‌تونین از همه امکانات\nبا هم استفاده کنین 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      color: Colors.black45)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text('بریم خونه 🏠',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 16,
                          color: Colors.white)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  @override
  void dispose() {
    _partnerIdController.dispose();
    _partnerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final userId = provider.userId.isNotEmpty ? provider.userId : '25486123';
    final canConnect = _partnerIdController.text.trim().length == 8;

    return ConfettiWidget(
      isPlaying: _showConfetti,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            if (_showEmoji)
              Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x80E87984),
                            blurRadius: 40,
                            spreadRadius: 8)
                      ]),
                  child: const Center(
                      child: Text('🎉', style: TextStyle(fontSize: 55)))),
            const SizedBox(height: 20),
            if (_showCongrats)
              const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ChatBubble(
                      text: '🎉 خوش اومدی به سایمو!\nثبت‌نامت کامل شد.',
                      isUser: false,
                      isHighlighted: true,
                      isCentered: true)),
            if (_showCard)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 10))
                    ],
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.15))),
                child: Column(children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20)),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.fingerprint,
                            size: 14, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('آیدی دائمی تو',
                            style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500))
                      ])),
                  const SizedBox(height: 16),
                  Text(_formatId(userId),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 6)),
                  const SizedBox(height: 8),
                  const Text('این آیدی همیشه معتبره ✅',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 11,
                          color: Color(0xFF4CAF50))),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () => _copyId(userId),
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ]),
                                child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.copy,
                                          color: Colors.white, size: 17),
                                      SizedBox(width: 8),
                                      Text('کپی آیدی',
                                          style: TextStyle(
                                              fontFamily: 'Vazir',
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600))
                                    ])))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {},
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withOpacity(0.2))),
                                child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.share_rounded,
                                          color: AppColors.primary, size: 17),
                                      SizedBox(width: 8),
                                      Text('اشتراک',
                                          style: TextStyle(
                                              fontFamily: 'Vazir',
                                              color: AppColors.primary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600))
                                    ])))),
                  ]),
                ]),
              ),
            const SizedBox(height: 28),
            if (_showTyping3) const TypingIndicator(),
            if (_showInviteMessage)
              const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: ChatBubble(
                      text: 'اگه آیدی عشقت رو داری،\nبفرست تا وصل بشین 💕',
                      isUser: false)),
            const SizedBox(height: 16),
            if (_showPartnerField)
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary
                              .withOpacity(canConnect ? 0.2 : 0.05),
                          blurRadius: canConnect ? 25 : 15,
                          offset: const Offset(0, 8))
                    ],
                    border: canConnect
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5)
                        : null),
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
                      color: Color(0xFF2D2D2D),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 5),
                  decoration: InputDecoration(
                      hintText: '12345678',
                      counterText: '',
                      hintStyle: const TextStyle(
                          fontFamily: 'Vazir',
                          color: Color(0xFFCCCCCC),
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.normal),
                      prefixIcon: Icon(
                          canConnect
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: canConnect
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          size: 24),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18)),
                  onChanged: (val) => setState(() {}),
                  onSubmitted: (_) {
                    if (canConnect) _connectPartner();
                  },
                ),
              ),
            const SizedBox(height: 20),
            if (_showPartnerField && canConnect)
              SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0),
                      onPressed: _isConnecting ? null : _connectPartner,
                      child: _isConnecting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Icon(Icons.link_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('وصل شو 💕',
                                      style: TextStyle(
                                          fontFamily: 'Vazir',
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700))
                                ]))),
            if (_showButtons) ...[
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: Container(height: 1, color: Colors.grey.shade200)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('یا',
                        style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 13,
                            color: Colors.grey.shade400))),
                Expanded(
                    child: Container(height: 1, color: Colors.grey.shade200))
              ]),
              const SizedBox(height: 16),
            ],
            if (_showButtons) ...[
              SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ورود به سایمو  ',
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                            Text('🏠', style: TextStyle(fontSize: 24))
                          ]))),
              const SizedBox(height: 12),
              GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(18)),
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('بعداً انجام می‌دم',
                                style: TextStyle(
                                    fontFamily: 'Vazir',
                                    fontSize: 14,
                                    color: Colors.black45)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.black38, size: 18)
                          ]))),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatId(String id) {
    if (id.length != 8) return id;
    return '${id.substring(0, 2)} ${id.substring(2, 4)} ${id.substring(4, 6)} ${id.substring(6, 8)}';
  }
}
