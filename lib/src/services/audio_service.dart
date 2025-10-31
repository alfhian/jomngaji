import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playFromAsset(String assetPath, {Function()? onComplete}) async {
    await _player.play(AssetSource(assetPath));
    _player.onPlayerComplete.listen((event) {
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
  }

  void dispose() {
    _player.dispose();
  }
}
