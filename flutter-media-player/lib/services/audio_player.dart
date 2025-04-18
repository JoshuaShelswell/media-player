// lib/services/audio_player.dart

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _CPlay = Void Function(Pointer<Utf8>);
typedef _PlayNative = void Function(Pointer<Utf8>);

typedef _CPause = Void Function();
typedef _PauseNative = void Function();

typedef _CResume = Void Function();
typedef _ResumeNative = void Function();

typedef _CStop = Void Function();
typedef _StopNative = void Function();

/// Dart-side API for our Rust engine.
class AudioPlayer extends ChangeNotifier {
  AudioPlayer._();
  static final AudioPlayer instance = AudioPlayer._();

  String? _currentPath;
  bool   _isPlaying   = false;

  String? get currentPath => _currentPath;
  bool   get isPlaying   => _isPlaying;

  Isolate?     _playIsolate;
  ReceivePort? _exitPort;

  // FFI bindings
  static final DynamicLibrary _lib = DynamicLibrary.open('rust_engine.dll');
  static final _PlayNative   _playFFI   = _lib.lookup<NativeFunction<_CPlay>>('play_audio_file').asFunction();
  static final _PauseNative  _pauseFFI  = _lib.lookup<NativeFunction<_CPause>>('pause_audio_file').asFunction();
  static final _ResumeNative _resumeFFI = _lib.lookup<NativeFunction<_CResume>>('resume_audio_file').asFunction();
  static final _StopNative   _stopFFI   = _lib.lookup<NativeFunction<_CStop>>('stop_audio').asFunction();

  /// Start playing [path]. If already playing, does nothing.
  Future<void> play(String path) async {
    if (_isPlaying) return;

    _currentPath = path;
    _isPlaying   = true;
    notifyListeners();

    final ptr = path.toNativeUtf8();

    // listen for the native thread exiting (track end)
    _exitPort = ReceivePort()..listen((_) {
      _isPlaying = false;
      notifyListeners();
      _exitPort?.close();
      _exitPort = null;
    });

    _playIsolate = await Isolate.spawn<_PlayParams>(
      _playEntry,
      _PlayParams(ptr.address),
      onExit: _exitPort!.sendPort,
    );
  }

  /// Pause playback (asks Rust to pause; does not kill isolate).
  Future<void> pause() async {
    if (!_isPlaying) return;
    _pauseFFI();
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume playback (asks Rust to resume on the same thread).
  Future<void> resume() async {
    if (_isPlaying || _currentPath == null) return;
    _resumeFFI();
    _isPlaying = true;
    notifyListeners();
  }

  /// Stop playback completely.
  Future<void> stop() async {
    if (!_isPlaying && _currentPath == null) return;

    // ask Rust to stop
    _stopFFI();

    // also kill isolate in case Rust didn't exit immediately
    _playIsolate?.kill(priority: Isolate.immediate);
    _playIsolate = null;

    _exitPort?.close();
    _exitPort = null;

    _isPlaying   = false;
    _currentPath = null;
    notifyListeners();
  }

  /// Toggle between pause & resume.
  Future<void> togglePause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  static void _playEntry(_PlayParams params) {
    final ptr = Pointer<Utf8>.fromAddress(params.ptrAddress);
    _playFFI(ptr);
    // when this returns, the isolate will exit and code in play()'s ReceivePort will fire
  }
}

class _PlayParams {
  final int ptrAddress;
  _PlayParams(this.ptrAddress);
}
