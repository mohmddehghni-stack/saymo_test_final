import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          child: ClipOval(
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Lottie.asset(
                      _lottieAsset,
                      width: size * 0.7,
                      height: size * 0.7,
                    ),
                    errorWidget: (context, url, error) => Lottie.asset(
                      _lottieAsset,
                      width: size * 0.7,
                      height: size * 0.7,
                    ),
                  )
                : Lottie.asset(
                    _lottieAsset,
                    width: size * 0.7,
                    height: size * 0.7,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
          ),
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
