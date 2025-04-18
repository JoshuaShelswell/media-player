// lib/services/player_model.dart

import 'package:flutter/foundation.dart';
import 'audio_player.dart';

/// Exposes play/pause/stop/seek for UI via ChangeNotifier.
class PlayerModel extends ChangeNotifier {
  final AudioPlayer _audio = AudioPlayer.instance;

  String? get currentPath => _audio.currentPath;
  bool   get isPlaying   => _audio.isPlaying;
  double get position    => _audio.position;
  double get duration    => _audio.duration;

  PlayerModel() {
    _audio.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _audio.removeListener(notifyListeners);
    // ensure we clean up the native isolate if this model is torn down
    _audio.stop();
    super.dispose();
  }

  Future<void> play(String path)     => _audio.play(path);
  Future<void> pause()               => _audio.pause();
  Future<void> resume()              => _audio.resume();
  Future<void> togglePause()         => _audio.togglePause();
  Future<void> stop()                => _audio.stop();

  /// Seek forward/backward by [seconds].
  /// TODO: wire this up to a `seek_audio` FFI call when available.
  Future<void> seekRelative(double seconds) async {
    debugPrint('Seek request: $seconds seconds');
  }
}
