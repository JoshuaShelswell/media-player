// lib/services/audio_player.dart

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _CPlay      = Void Function(Pointer<Utf8>);
typedef _PlayNative = void Function(Pointer<Utf8>);

typedef _CStop      = Void Function();
typedef _StopNative = void Function();

typedef _CGetPos    = Float Function();
typedef _PosNative  = double Function();

/// Dart-side API for our Rust engine.
class AudioPlayer extends ChangeNotifier {
  AudioPlayer._();
  static final AudioPlayer instance = AudioPlayer._();

  String? _currentPath;
  double _duration = 0.0;
  double _position = 0.0;
  bool   _isPlaying = false;

  String?  get currentPath => _currentPath;
  double   get duration    => _duration;
  double   get position    => _position;
  bool     get isPlaying   => _isPlaying;

  Isolate? _playIsolate;
  ReceivePort? _exitPort;
  Timer?      _positionTimer;

  // FFI bindings (we only look up stop & get_position here;
  // play is invoked from inside the spawned isolate).
  static final DynamicLibrary _lib = DynamicLibrary.open('rust_engine.dll');
  static final _StopNative _stopFFI =
      _lib.lookup<NativeFunction<_CStop>>('stop_audio').asFunction();
  static final _PosNative _posFFI =
      _lib.lookup<NativeFunction<_CGetPos>>('get_position_seconds').asFunction();

  /// Start playing [path].  Stops any existing playback first.
  Future<void> play(String path) async {
    await stop();

    _currentPath = path;
    _isPlaying   = true;
    notifyListeners();

    // spawn an isolate to call the FFI `play_audio_file`
    final ptr = path.toNativeUtf8();

    // set up a port so we know when the isolate (and thus playback) exits
    _exitPort = ReceivePort()..listen((_) {
      // native play returned (track ended or stopped)
      _isPlaying = false;
      _positionTimer?.cancel();
      notifyListeners();
      _exitPort!.close();
      _exitPort = null;
    });

    _playIsolate = await Isolate.spawn<_PlayParams>(
      _playEntry,
      _PlayParams(ptr.address),
      onExit: _exitPort!.sendPort,
      // we don't need onError for now
    );

    // start polling position every 200ms
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
    if (!_isPlaying) return;

    _isPlaying = false;
    notifyListeners();

    _positionTimer?.cancel();
    _stopFFI();

    // kill the isolate if it's still around
    _playIsolate?.kill(priority: Isolate.immediate);
    _playIsolate = null;

    // clean up exit port
    _exitPort?.close();
    _exitPort = null;
  }

  /// Toggle between pause and resume.
  Future<void> togglePause() async {
    if (_isPlaying) {
      // pausing is just a stop in our FFI
      await stop();
    } else if (_currentPath != null) {
      // resume by re‑playing the same file
      await play(_currentPath!);
    }
  }

  /// Entry point for our spawned isolate.
  /// Looks up `play_audio_file` and calls it.
  static void _playEntry(_PlayParams params) {
    final ptr = Pointer<Utf8>.fromAddress(params.ptrAddress);
    final dylib = DynamicLibrary.open('rust_engine.dll');
    final playFFI = dylib
        .lookup<NativeFunction<_CPlay>>('play_audio_file')
        .asFunction<_PlayNative>();
    playFFI(ptr);
    // when this returns, isolate will exit and notify main isolate
  }
}

/// Simple struct to pass the raw pointer address into the isolate.
class _PlayParams {
  final int ptrAddress;
  _PlayParams(this.ptrAddress);
}
