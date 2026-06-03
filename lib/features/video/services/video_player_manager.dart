import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import '../../../shared/services/socket_service.dart';

class VideoPlayerManager {
  VideoPlayerController? _controller;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  bool _isPlaying = false;
  bool _isLoading = false;

  VideoPlayerController? get controller => _controller;
  double get playbackSpeed => _playbackSpeed;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isLoading => _isLoading;

  Function()? onStateChanged;
  VoidCallback? onError;

  Future<bool> loadVideo(String url) async {
    try {
      _isLoading = true;
      onStateChanged?.call();

      await _controller?.dispose();
      _controller = null;

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': '*/*',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
        },
      );

      _controller!.addListener(() {
        if (_controller!.value.hasError) {
          debugPrint('❌ خطای پخش: ${_controller!.value.errorDescription}');
          onError?.call();
        }
        onStateChanged?.call();
      });

      await _controller!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('⏰ زمان لود ویدیو تمام شد');
        },
      );

      _controller!.setVolume(_volume);
      await Future.delayed(const Duration(milliseconds: 200));

      _controller!.play();
      _isPlaying = true;
      _isLoading = false;

      onStateChanged?.call();
      return true;
    } catch (e) {
      debugPrint('❌ خطای لود ویدیو: $e');
      _isLoading = false;
      _isPlaying = false;
      onError?.call();
      onStateChanged?.call();
      return false;
    }
  }

  // 👈 togglePlay با پارامتر fromRemote
  void togglePlay({bool fromRemote = false}) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      if (!fromRemote) SocketService.send('pause');
    } else {
      _controller!.play();
      if (!fromRemote) SocketService.send('play');
    }
    _isPlaying = _controller!.value.isPlaying;
    onStateChanged?.call();
  }

  void seekRelative(int seconds) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final newPosition =
        _controller!.value.position + Duration(seconds: seconds);
    seekTo(newPosition, fromRemote: false);
  }

  // 👈 seekTo با پارامتر fromRemote
  void seekTo(Duration position, {bool fromRemote = false}) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final duration = _controller!.value.duration;
    final clampedPosition = position.inMilliseconds < 0
        ? Duration.zero
        : position.inMilliseconds > duration.inMilliseconds
            ? duration
            : position;

    _controller!.seekTo(clampedPosition);

    // 👈 فقط اگه از ریموت نیومده، بفرست
    if (!fromRemote) {
      SocketService.send('seek', data: {
        'time': clampedPosition.inSeconds.toDouble(),
      });
    }
  }

  void cyclePlaybackSpeed() {
    if (_playbackSpeed == 1.0) {
      _playbackSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      _playbackSpeed = 2.0;
    } else {
      _playbackSpeed = 1.0;
    }
    _controller?.setPlaybackSpeed(_playbackSpeed);
    onStateChanged?.call();

    SocketService.send('speed_change', data: {
      'speed': _playbackSpeed,
    });
  }

  void setVolume(double value) {
    _volume = value;
    _controller?.setVolume(value);
    onStateChanged?.call();
  }

  double get progress {
    if (_controller == null || !_controller!.value.isInitialized) return 0.0;
    final duration = _controller!.value.duration.inSeconds;
    if (duration == 0) return 0.0;
    return _controller!.value.position.inSeconds / duration;
  }

  Duration get position => _controller?.value.position ?? Duration.zero;
  Duration get duration => _controller?.value.duration ?? Duration.zero;

  void dispose() {
    _controller?.removeListener(() {});
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    onStateChanged = null;
    onError = null;
  }
}
