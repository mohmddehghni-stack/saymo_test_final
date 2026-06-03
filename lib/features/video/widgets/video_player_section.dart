import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';
import '../services/video_player_manager.dart';

class VideoPlayerSection extends StatelessWidget {
  final VideoPlayerManager playerManager;
  final VoidCallback onToggleFullScreen;
  final bool isFullScreen;

  const VideoPlayerSection({
    super.key,
    required this.playerManager,
    required this.onToggleFullScreen,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    // 👈 اگه اصلاً controller نداریم
    if (playerManager.controller == null) {
      return const SizedBox.shrink();
    }

    // 👈 اگه در حال لود کردن هست (صدا میاد ولی تصویر نه)
    if (playerManager.isLoading || !playerManager.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.pinkAccent),
              SizedBox(height: 16),
              Text(
                'در حال لود ویدیو... 🎬',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 👈 ویدیو آماده است
    return AspectRatio(
      aspectRatio: playerManager.controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(playerManager.controller!),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: playerManager.progress,
                      minHeight: 5,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.pinkAccent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _controlButton(Icons.replay_10,
                          () => playerManager.seekRelative(-10)),
                      const Spacer(),
                      _controlButton(
                        playerManager.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        () => playerManager.togglePlay(),
                        size: 32,
                      ),
                      const Spacer(),
                      _controlButton(Icons.forward_10,
                          () => playerManager.seekRelative(10)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          _formatDuration(
                              playerManager.position.inSeconds.toDouble()),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => playerManager.cyclePlaybackSpeed(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text('${playerManager.playbackSpeed}x',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: onToggleFullScreen,
                            child: Icon(
                                isFullScreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white70,
                                size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap, {double size = 22}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
