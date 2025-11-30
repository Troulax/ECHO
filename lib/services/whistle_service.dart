import 'package:audioplayers/audioplayers.dart';

class WhistleService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _running = false;

  static Future<void> start() async {
    if (_running) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
    await _player.play(AssetSource('sounds/whistle.wav'));

    _running = true;
  }

  static Future<void> stop() async {
    if (!_running) return;

    await _player.stop();
    _running = false;
  }

  static bool get isRunning => _running;
}
