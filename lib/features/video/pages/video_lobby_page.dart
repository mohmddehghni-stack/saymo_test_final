import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'cinema_room_page.dart';
import '../../../core/providers/app_provider.dart';

class VideoLobbyPage extends StatefulWidget {
  const VideoLobbyPage({super.key});

  @override
  State<VideoLobbyPage> createState() => _VideoLobbyPageState();
}

class _VideoLobbyPageState extends State<VideoLobbyPage> {
  void _enterCinemaRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CinemaRoomPage()),
    );
  }

  Future<Map<String, dynamic>?> _checkRoomStatus(String partnerId) async {
    try {
      final uri =
          Uri.parse('https://couple-api.liara.run/api/room-status/$partnerId');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildContinueWatchingButton(String partnerId) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _checkRoomStatus(partnerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final isOpen = data['isOpen'] == true;
        final hasVideo = data['hasVideo'] == true;

        if (!isOpen || !hasVideo) return const SizedBox.shrink();

        return GestureDetector(
          onTap: _enterCinemaRoom,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepPurple]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text('🎬 ادامه تماشای ویدیو',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Vazir',
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final hasPartner = appProvider.partnerId != null;
    final partnerName = appProvider.partnerUsername ?? 'پارتنر';

    return Scaffold(
      backgroundColor: const Color(0xFF1A0E2A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 5)
                    ],
                  ),
                  child: const Center(
                      child: Text('🍿', style: TextStyle(fontSize: 56))),
                ),
                const SizedBox(height: 32),
                const Text('سینمای دونفره',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Vazir',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('با $partnerName فیلم ببینید و لذت ببرید',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontFamily: 'Vazir')),
                const SizedBox(height: 32),

                // 👈 دکمه ادامه تماشا
                if (hasPartner)
                  _buildContinueWatchingButton(appProvider.partnerId!),

                if (hasPartner) const SizedBox(height: 16),

                // 👈 دکمه ورود به سینما
                GestureDetector(
                  onTap: _enterCinemaRoom,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text('ورود به سینما 🎬',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Vazir',
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color:
                                hasPartner ? Colors.greenAccent : Colors.grey,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(
                        hasPartner
                            ? '$partnerName پارتنر توئه ❤️'
                            : 'هنوز پارتنر نداری',
                        style: TextStyle(
                            color: hasPartner
                                ? Colors.white.withOpacity(0.8)
                                : Colors.white.withOpacity(0.4),
                            fontSize: 14,
                            fontFamily: 'Vazir')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
