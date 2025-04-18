// lib/services/player_model.dart

import 'package:flutter/material.dart';
import 'audio_player.dart';

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
    _audio.stop();
    super.dispose();
  }

  Future<void> play(String path)     => _audio.play(path);
  Future<void> pause()               => _audio.pause();
  Future<void> resume()              => _audio.resume();
  Future<void> togglePause()         => _audio.togglePause();
  Future<void> stop()                => _audio.stop();
}
