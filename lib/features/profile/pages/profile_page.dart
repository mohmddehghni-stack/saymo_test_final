import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/core/providers/app_provider.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_id_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_partner_card.dart';
import '../widgets/theme_section.dart';
import '../widgets/support_button.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/partner_info_card.dart';
import 'package:flutter_application_1/shared/widgets/avatar_picker_dialog.dart';
import 'package:flutter_application_1/shared/services/image_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/shared/services/api_service.dart';
import 'package:flutter_application_1/features/auth/pages/welcome_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiService.getProfile();
      if (response['user'] != null) {
        final user = response['user'];
        final appProvider = context.read<AppProvider>();

        // 🔥 اطلاعات پایه
        if (user['display_name'] != null) {
          appProvider.setDisplayName(user['display_name']);
        }
        if (user['username'] != null) {
          appProvider.setUsername(user['username']);
        }
        if (user['avatar_url'] != null) {
          appProvider.setAvatarUrl(user['avatar_url']);
        }

        // 🔥 coupleId (جدید)
        if (user['couple_id'] != null) {
          appProvider.setCoupleId(user['couple_id']);
        }

        // 🔥 اطلاعات پارتنر (اگر وجود داشت)
        final partner = response['partner'];
        if (partner != null) {
          appProvider.connectPartner(
            partner['username'] ?? '',
            partnerId: partner['id']?.toString(),
            displayName: partner['display_name'],
            partnerGender: partner['gender'],
          );
        }

        // 🔥 آپدیت UI
        setState(() {
          _userData = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded,
                    color: Colors.red.shade400, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('حذف حساب کاربری',
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'این عملیات غیرقابل بازگشته!\nهمه اطلاعاتت برای همیشه پاک میشه 💔',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 13,
                      color: Colors.black54)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('انصراف',
                        style: TextStyle(fontFamily: 'Vazir')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await context.read<AppProvider>().deleteAccount();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const WelcomePage()),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطا در حذف حساب: $e',
                                  style: const TextStyle(fontFamily: 'Vazir')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('حذف کن',
                        style: TextStyle(
                            fontFamily: 'Vazir', color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _userData ?? {};

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  username: appProvider.displayName ??
                      appProvider.username ??
                      'کاربر',
                  userId: _userData?['public_id'] ?? '',
                  gender: _userData?['gender'] ?? 'male',
                  imageUrl: _userData?['avatar_url'],
                  onLogout: () => showLogoutDialog(context),
                  onCameraTap: () async {
                    final result = await AvatarPickerDialog.show(context,
                        hasImage: _userData?['avatar_url'] != null);

                    if (result == 'delete') {
                      // 🔥 حذف لوکال
                      setState(() => _userData?.remove('avatar_url'));
                      appProvider.setAvatarUrl(null);

                      // 🔥 notify سرور برای پارتنر
                      try {
                        await http.post(
                          Uri.parse(
                              '${ApiService.baseUrl}/upload/avatar-delete'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${ApiService.token}',
                          },
                        );
                      } catch (e) {}
                    } else if (result != null && mounted) {
                      // 🔥 آپلود روی سرور
                      final avatarUrl = await ImageService.uploadAvatar(result);
                      if (avatarUrl != null) {
                        setState(() {
                          if (_userData != null) {
                            _userData!['avatar_url'] = avatarUrl;
                          } else {
                            _userData = {'avatar_url': avatarUrl};
                          }
                        });
                        appProvider.setAvatarUrl(avatarUrl);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                ProfileIdCard(
                  publicId: user['public_id'] ?? '',
                  onCopy: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('آیدی کپی شد! 📋',
                              style: TextStyle(fontFamily: 'Vazir'))),
                    );
                  },
                ),
                const SizedBox(height: 12),

                PartnerInfoCard(
                  displayName: appProvider.partnerDisplayName ??
                      appProvider.partnerUsername,
                  username: appProvider.partnerId,
                  imageUrl: appProvider.partnerAvatarUrl,
                  gender: appProvider.partnerGender, // 🔥 از سرور
                ),
                const SizedBox(height: 12),
                // تو profile_page.dart:
                ProfileInfoCard(
                  displayName: appProvider.displayName ?? '',
                  username: appProvider.username ?? '',
                  phone: _userData?['phone'] ?? '',
                  gender: _userData?['gender'] ?? '',
                ),
                const SizedBox(height: 12),
                ProfilePartnerCard(
                  isConnected: appProvider.isConnected,
                  partnerName: appProvider.partnerUsername,
                ),
                const SizedBox(height: 12),
                const ThemeSection(),
                const SizedBox(height: 10),
                const SupportButton(),
                const SizedBox(height: 10),
                // 🗑️ دکمه حذف حساب
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => _showDeleteAccountDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever_rounded,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('حذف حساب کاربری',
                              style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          height: 68,
          width: 68,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            elevation: 8,
            shape: const CircleBorder(),
            onPressed: () {},
            child: const Icon(Icons.play_arrow_rounded,
                size: 45, color: Colors.white),
          ),
        ),
        bottomNavigationBar: buildBottomNav(context, activePage: 'profile'),
      ),
    );
  }
}
