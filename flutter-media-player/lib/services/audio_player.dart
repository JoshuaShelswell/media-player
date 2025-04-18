// lib/services/audio_player.dart

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Dart-side API for our Rust engine.
class AudioPlayer extends ChangeNotifier {
  AudioPlayer._();
  static final AudioPlayer instance = AudioPlayer._();

  /// “now playing” path
  String? _currentPath;
  String? get currentPath => _currentPath;

  /// total duration (seconds)
  final double _duration = 0.0;
  double get duration => _duration;

  /// current playhead (seconds)
  double _position = 0.0;
  double get position => _position;

  /// are we playing?
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Isolate? _playbackIsolate;
  Timer?   _positionTimer;

  /// FFI bindings
  static final DynamicLibrary _lib = DynamicLibrary.open('rust_engine.dll');
  static final _PlayNative _playFFI = _lib
      .lookup<NativeFunction<_CPlay>>('play_audio_file')
      .asFunction();
  static final _StopNative _stopFFI = _lib
      .lookup<NativeFunction<_CStop>>('stop_audio')
      .asFunction();
  static final _PosNative _posFFI = _lib
      .lookup<NativeFunction<_CGetPos>>('get_position_seconds')
      .asFunction();

  /// Start playing [path].  Non‐blocking.
  Future<void> play(String path) async {
    await stop(); // stop any existing playback first
    _currentPath = path;
    _isPlaying   = true;
    notifyListeners();

    // spawn FFI call off the UI thread
    final ptr = path.toNativeUtf8();
    await compute<_PlayArgs, void>(
      _spawnPlay,
      _PlayArgs(ptr, _playFFI),
    );
    malloc.free(ptr);

    // start polling position
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) {
        if (!_isPlaying) return;
        _position = _posFFI();
        notifyListeners();
      },
    );
  }

  /// Stop playback immediately.
  Future<void> stop() async {
    if (_isPlaying) {
      _isPlaying = false;
      notifyListeners();
      _positionTimer?.cancel();
      _stopFFI();
      // also kill isolate if you spawned one:
      _playbackIsolate?.kill(priority: Isolate.immediate);
      _playbackIsolate = null;
    }
  }

  /// Pause/resume
  Future<void> togglePause() async {
    if (_isPlaying) {
      _stopFFI();
      _isPlaying = false;
    } else if (_currentPath != null) {
      // re‐play from current path (Rust should resume)
      await play(_currentPath!);
    }
    notifyListeners();
  }

  /// callback for compute()
  static void _spawnPlay(_PlayArgs args) {
    args.play(args.ptr);
  }
}

/// small wrapper to pass pointer + function into isolate
class _PlayArgs {
  final Pointer<Utf8> ptr;
  final _PlayNative  play;
  _PlayArgs(this.ptr, this.play);
}

/// FFI typedefs
typedef _CPlay     = Void Function(Pointer<Utf8>);
typedef _PlayNative= void Function(Pointer<Utf8>);

typedef _CStop     = Void Function();
typedef _StopNative= void Function();

typedef _CGetPos    = Float Function();
typedef _PosNative = double Function();
