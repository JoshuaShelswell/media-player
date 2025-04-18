// lib/services/player_model.dart

import 'package:flutter/material.dart';
import 'audio_player.dart';

/// A small ChangeNotifier wrapper so you can bind your UI
/// to playback state without static calls.
class PlayerModel extends ChangeNotifier {
  // grab the singleton
  final AudioPlayer _audio = AudioPlayer.instance;

  /// Expose what you need to your UI:
  String? get currentPath => _audio.currentPath;
  double get duration     => _audio.duration;
  double get position     => _audio.position;
  bool   get isPlaying    => _audio.isPlaying;

  PlayerModel() {
    // forward audio‐player changes to listeners
    _audio.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _audio.removeListener(notifyListeners);
    super.dispose();
  }

  /// Start playback of [path]
  Future<void> play(String path) => _audio.play(path);

  /// Stop playback
  Future<void> stop() => _audio.stop();

  /// Pause / resume
  Future<void> togglePause() => _audio.togglePause();
}
