// lib/services/player_model.dart

import 'package:flutter/material.dart';
import 'audio_player.dart';

/// A ChangeNotifier wrapper so you can bind your UI
/// to playback state without static calls.
class PlayerModel extends ChangeNotifier {
  final AudioPlayer _audio = AudioPlayer.instance;

  String? get currentPath => _audio.currentPath;
  double get duration    => _audio.duration;
  double get position    => _audio.position;
  bool   get isPlaying   => _audio.isPlaying;

  PlayerModel() {
    _audio.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _audio.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> play(String path) => _audio.play(path);
  Future<void> stop()           => _audio.stop();
  Future<void> togglePause()    => _audio.togglePause();
}
