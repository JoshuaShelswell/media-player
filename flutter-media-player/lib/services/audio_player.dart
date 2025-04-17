// lib/services/audio_player.dart

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

/// Attempt to load the Rust engine library from the app folder,
/// falling back to the executable’s directory if needed.
DynamicLibrary _openRustEngineLib() {
  if (Platform.isWindows) {
    try {
      return DynamicLibrary.open('rust_engine.dll');
    } catch (_) {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      return DynamicLibrary.open('$exeDir${Platform.pathSeparator}rust_engine.dll');
    }
  } else if (Platform.isLinux) {
    try {
      return DynamicLibrary.open('librust_engine.so');
    } catch (_) {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      return DynamicLibrary.open('$exeDir${Platform.pathSeparator}librust_engine.so');
    }
  } else if (Platform.isMacOS) {
    try {
      return DynamicLibrary.open('librust_engine.dylib');
    } catch (_) {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      return DynamicLibrary.open('$exeDir${Platform.pathSeparator}librust_engine.dylib');
    }
  }
  throw UnsupportedError('Unsupported platform');
}

final DynamicLibrary _audioLib = _openRustEngineLib();

// C signature: extern "C" fn play_audio_file_ffi(file_path: *const c_char) -> i32;
typedef _PlayAudioC = Int32 Function(Pointer<Utf8> filePath);
typedef _PlayAudioD = int Function(Pointer<Utf8> filePath);

final _PlayAudioD _playAudio = _audioLib
    .lookup<NativeFunction<_PlayAudioC>>('play_audio_file_ffi')
    .asFunction();

class AudioPlayer {
  /// Play the given file path via the Rust engine. Returns 0 on success.
  static int play(String filePath) {
    final ptr = filePath.toNativeUtf8();
    final result = _playAudio(ptr);
    malloc.free(ptr);
    return result;
  }
}
