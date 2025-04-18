// lib/services/audio_player.dart

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _CPlay   = Void Function(Pointer<Utf8>);
typedef _CPause  = Void Function();
typedef _CResume = Void Function();
typedef _CStop   = Void Function();
typedef _CPos    = Float Function();
typedef _CDur    = Float Function();
typedef _CSetVol = Void Function(Float);
typedef _CSeek   = Void Function(Float);

typedef _PlayFn   = void Function(Pointer<Utf8>);
typedef _PauseFn  = void Function();
typedef _ResumeFn = void Function();
typedef _StopFn   = void Function();
typedef _PosFn    = double Function();
typedef _DurFn    = double Function();
typedef _SetVolFn = void Function(double);
typedef _SeekFn   = void Function(double);

class AudioPlayer extends ChangeNotifier {
  AudioPlayer._();
  static final AudioPlayer instance = AudioPlayer._();

  String? _currentPath;
  bool   _isPlaying   = false;
  double _position    = 0.0;
  double _duration    = 0.0;

  String? get currentPath => _currentPath;
  bool   get isPlaying   => _isPlaying;
  double get position    => _position;
  double get duration    => _duration;

  Isolate?     _playIso;
  ReceivePort? _exitPort;
  Timer?       _pollTimer;

  static final DynamicLibrary _lib = Platform.isWindows
      ? DynamicLibrary.open('rust_engine.dll')
      : DynamicLibrary.process();

  static final _PlayFn   _playFFI   = _lib
      .lookup<NativeFunction<_CPlay>>('play_audio_file')
      .asFunction();
  static final _PauseFn  _pauseFFI  = _lib
      .lookup<NativeFunction<_CPause>>('pause_audio_file')
      .asFunction();
  static final _ResumeFn _resumeFFI = _lib
      .lookup<NativeFunction<_CResume>>('resume_audio_file')
      .asFunction();
  static final _StopFn   _stopFFI   = _lib
      .lookup<NativeFunction<_CStop>>('stop_audio')
      .asFunction();
  static final _PosFn    _posFFI    = _lib
      .lookup<NativeFunction<_CPos>>('get_position_seconds')
      .asFunction();
  static final _DurFn    _durFFI    = _lib
      .lookup<NativeFunction<_CDur>>('get_duration_seconds')
      .asFunction();

  static final _SetVolFn _setVolFFI = _lib
      .lookup<NativeFunction<_CSetVol>>('set_volume')
      .asFunction();
  static final _SeekFn   _seekFFI   = _lib
      .lookup<NativeFunction<_CSeek>>('seek_audio')
      .asFunction();

  Future<void> play(String path) async {
    // ensure previous playback is fully stopped
    await stop();
    // give the Rust decoder a moment to see the stop flag and exit
    await Future.delayed(const Duration(milliseconds: 100));

    _currentPath = path;
    _isPlaying   = true;
    notifyListeners();

    final port = ReceivePort();
    _exitPort = port;
    port.listen((_) {
      _isPlaying = false;
      _pollTimer?.cancel();
      notifyListeners();
      port.close();
      if (_exitPort == port) {
        _exitPort = null;
      }
    });

    final ptr = path.toNativeUtf8();
    _playIso = await Isolate.spawn<_PlayParams>(
      _playEntry,
      _PlayParams(ptr.address),
      onExit: port.sendPort,
    );

    _pollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_isPlaying) return;
      _position = _posFFI();
      _duration = _durFFI();
      notifyListeners();
    });
  }

  Future<void> pause() async {
    if (!_isPlaying) return;
    _pauseFFI();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_isPlaying || _currentPath == null) return;
    _resumeFFI();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> stop() async {
    if (_playIso != null) {
      _stopFFI();
      _playIso!.kill(priority: Isolate.immediate);
      _playIso = null;
    }

    _pollTimer?.cancel();
    _pollTimer = null;

    _exitPort?.close();
    _exitPort = null;

    _isPlaying   = false;
    _currentPath = null;
    _position    = 0.0;
    _duration    = 0.0;
    notifyListeners();
  }

  Future<void> togglePause() => isPlaying ? pause() : resume();

  Future<void> seek(double sec) async {
    _seekFFI(sec);
    _position = sec;
    notifyListeners();
  }

  Future<void> setVolume(double level) async {
    _setVolFFI(level);
    notifyListeners();
  }

  static void _playEntry(_PlayParams p) {
    _playFFI(Pointer<Utf8>.fromAddress(p.ptr));
  }
}

class _PlayParams {
  final int ptr;
  _PlayParams(this.ptr);
}
