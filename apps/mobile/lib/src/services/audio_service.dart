import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  StreamSubscription<void>? _completionSubscription;

  Future<void> playFromAsset(String assetPath, {Function()? onComplete}) async {
    await stop();

    _completionSubscription?.cancel();
    _isPlaying = true;
    await _player.play(AssetSource(assetPath));
    _completionSubscription = _player.onPlayerComplete.listen((event) {
      _isPlaying = false;
      if (onComplete != null) onComplete();
    });
  }

  Future<void> pause() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    await _completionSubscription?.cancel();
    _completionSubscription = null;
  }

  void dispose() {
    _completionSubscription?.cancel();
    _player.dispose();
  }
}
