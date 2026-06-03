import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/registration_provider.dart';
import '../widgets/registration_progress.dart';
import 'register_step1_page.dart';
import 'register_step2_page.dart';
import 'register_step3_page.dart';
import 'register_step4_page.dart';

class RegisterNewPage extends StatefulWidget {
  const RegisterNewPage({super.key});

  @override
  State<RegisterNewPage> createState() => _RegisterNewPageState();
}

class _RegisterNewPageState extends State<RegisterNewPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();

    // گوش دادن به تغییرات currentStep و رفتن به صفحه مربوطه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != provider.currentStep) {
        _goToPage(provider.currentStep);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            RegistrationProgress(currentStep: provider.currentStep),
            const SizedBox(height: 30),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  RegisterStep1Page(),
                  RegisterStep2Page(),
                  RegisterStep3Page(),
                  RegisterStep4Page(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
