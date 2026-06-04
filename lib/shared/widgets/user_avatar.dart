import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String username;
  final String gender;
  final double size;
  final bool showCameraButton;
  final VoidCallback? onCameraTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.username,
    required this.gender,
    this.size = 72,
    this.showCameraButton = false,
    this.onCameraTap,
  });

  Color get _bgColor =>
      gender == 'female' ? const Color(0xFFFFE0E8) : const Color(0xFFE0EAFF);

  String get _lottieAsset => gender == 'female'
      ? 'assets/lottie/female_avatar.json'
      : 'assets/lottie/male_avatar.json';

  // 🔥 تشخیص نوع عکس
  Widget _buildImage() {
    if (imageUrl == null) {
      return _buildLottie();
    }

    // اگه Base64 باشه
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64Data = imageUrl!.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildLottie(),
        );
      } catch (e) {
        return _buildLottie();
      }
    }

    // اگه URL باشه (https://...)
    if (imageUrl!.startsWith('http')) {
      // اینجا میتونی از CachedNetworkImage استفاده کنی
      // ولی چون عکس‌ها Base64 هستن، به این حالت نمیرسیم
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildLottie(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLottie();
        },
      );
    }

    // حالت پیش‌فرض
    return _buildLottie();
  }

  Widget _buildLottie() {
    return Lottie.asset(
      _lottieAsset,
      width: size * 0.7,
      height: size * 0.7,
      fit: BoxFit.contain,
      repeat: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _bgColor,
            boxShadow: [
              BoxShadow(
                color: _bgColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: _buildImage()),
        ),
        if (showCameraButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onCameraTap,
              child: Container(
                width: size * 0.38,
                height: size * 0.38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: _bgColor, size: size * 0.2),
              ),
            ),
          ),
      ],
    );
  }
}
