import 'package:flutter/foundation.dart';
import 'audio_player.dart';

class PlayerModel extends ChangeNotifier {
  final AudioPlayer _audio = AudioPlayer.instance;

  String? get currentPath => _audio.currentPath;
  bool   get isPlaying   => _audio.isPlaying;
  bool   get completed   => _audio.completed;  // ← New getter
  double get position    => _audio.position;
  double get duration    => _audio.duration;

  // ─────────── REPEAT FLAG ───────────
  bool get repeatEnabled => _repeatEnabled;
  bool _repeatEnabled = false;
  void toggleRepeat() {
    _repeatEnabled = !_repeatEnabled;
    notifyListeners();
  }

  PlayerModel() {
    _audio.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _audio.removeListener(notifyListeners);
    _audio.stop();
    super.dispose();
  }

  Future<void> play(String path)     => _audio.play(path);
  Future<void> pause()               => _audio.pause();
  Future<void> resume()              => _audio.resume();
  Future<void> togglePause()         => _audio.togglePause();
  Future<void> stop()                => _audio.stop();

  /// Seek to absolute position [seconds].
  Future<void> seek(double seconds)  => _audio.seek(seconds);

  /// Seek relative by [seconds]; clamped between 0 and duration.
  Future<void> seekRelative(double seconds) async {
    final newPos = (position + seconds).clamp(0.0, duration);
    return seek(newPos);
  }

  /// Set playback volume (0.0–1.0).
  Future<void> setVolume(double level) => _audio.setVolume(level);
}
