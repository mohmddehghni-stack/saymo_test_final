import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class RegisterChatPage extends StatefulWidget {
  const RegisterChatPage({super.key});

  @override
  State<RegisterChatPage> createState() => _RegisterChatPageState();
}

class _RegisterChatPageState extends State<RegisterChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final List<Widget> _messages = [];
  int _step = 0; // 0=name, 1=phone, 2=password, 3=done
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _startConversation() async {
    await _addBotMessage('خوش اومدی! 😍');
    await _addBotMessage('عشقت چی صدات می‌کنه؟');
  }

  Future<void> _addBotMessage(String text) async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isTyping = false;
      _messages.add(ChatBubble(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatBubble(text: text, isUser: true));
    });
    _scrollToBottom();
    _processUserInput(text);
  }

  Future<void> _processUserInput(String text) async {
    final provider = context.read<RegistrationProvider>();

    switch (_step) {
      case 0: // اسم
        provider.setDisplayName(text);
        await _addBotMessage('چه اسم قشنگی! ${text} جان 💕');
        await _addBotMessage('حالا شماره تلفنت رو بگو 📱');
        setState(() => _step = 1);
        break;

      case 1: // شماره
        if (text.startsWith('09') && text.length == 11) {
          provider.setPhone(text);
          await _addBotMessage('گرفتمش! 📥');
          await _addBotMessage('فقط چک می‌کنم ببینم تکراری نیستی...');
          await Future.delayed(const Duration(seconds: 1));
          await _addBotMessage('نه! اولین باره می‌بینمت! 😍');
          await _addBotMessage('حالا یه رمز برای خونه‌مون انتخاب کن 🔐');
          await _addBotMessage('حداقل ۶ تا باشه، آسون نذار ها!');
          setState(() => _step = 2);
        } else {
          await _addBotMessage(
              'شماره موبایل معتبر نیست! با 09 شروع بشه و 11 رقم باشه 📵');
        }
        break;

      case 2: // رمز
        if (text.length >= 6) {
          provider.setPassword(text);
          await _addBotMessage('آفرین! رمزت رو توی کیفم قایم کردم 🤫');
          await _addBotMessage('دارم ثبت‌نامت رو انجام می‌دم... ⏳');

          try {
            final response = await ApiService.register(
              provider.displayName,
              provider.username,
              provider.phone,
              provider.password,
              provider.gender, // 👈 'male' رو با provider.gender جایگزین کن
            );

            if (response['token'] != null) {
              ApiService.setToken(response['token']);
              provider
                  .setUserId(response['user']['id'].toString().padLeft(8, '0'));
              await _addBotMessage('خوش اومدی به خونه‌مون! 🏠💕');
              await _addBotMessage('آیدی تو: ${provider.userId}');
              await _addBotMessage('بفرس برای عشقت تا وصل بشین 💌');
              setState(() => _step = 3);
            } else {
              await _addBotMessage('یه مشکلی پیش اومد! دوباره امتحان کن 🥺');
            }
          } catch (e) {
            await _addBotMessage('نت قطعه! دوباره امتحان کن 📡');
          }
        } else {
          await _addBotMessage('رمزه باید حداقل ۶ کاراکتر باشه! دوباره بگو 🔐');
        }
        break;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _addUserMessage(text);
    _inputController.clear();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      body: SafeArea(
        child: Column(
          children: [
            // هدر
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark]),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Text('💕', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  const Text('سایمو',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('مرحله ${_step + 1} از ۴',
                      style: TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 12,
                          color: Colors.black45)),
                ],
              ),
            ),

            // پیام‌ها
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return const TypingIndicator();
                  }
                  return _messages[index];
                },
              ),
            ),

            // فیلد ورودی (فقط تا مرحله ۳)
            if (_step < 3)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textDirection: TextDirection.rtl,
                        keyboardType: _step == 1
                            ? TextInputType.phone
                            : TextInputType.text,
                        obscureText: _step == 2,
                        style:
                            const TextStyle(fontFamily: 'Vazir', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _step == 0
                              ? 'اسمت رو بنویس...'
                              : _step == 1
                                  ? '09xxxxxxxxx'
                                  : 'رمز رو بنویس...',
                          hintStyle: const TextStyle(
                              fontFamily: 'Vazir', color: Colors.black26),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.primary,
                            AppColors.primaryDark
                          ]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

            // دکمه‌های مرحله ۴
            if (_step == 3)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/home'),
                        child: const Text('ورود به سایمو 🏠',
                            style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 16,
                                color: Colors.white)),
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
}
