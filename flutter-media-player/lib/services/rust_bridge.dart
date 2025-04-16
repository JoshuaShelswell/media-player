// media-player-project/flutter-media-player/lib/services/rust_bridge.dart
import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

// Define the native function signature for Rust's play_audio function.
typedef PlayAudioFunc = Void Function(Pointer<Utf8>);
typedef PlayAudio = void Function(Pointer<Utf8>);

class RustBridge {
  // Load the Rust dynamic library (update the filename as needed for your platform).
  static final DynamicLibrary _dylib = () {
    if (Platform.isWindows) {
      return DynamicLibrary.open('rust_engine.dll');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('librust_engine.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('librust_engine.dylib');
    } else {
      throw UnsupportedError("Platform not supported for Rust FFI.");
    }
  }();

  static final PlayAudio _playAudio = _dylib
      .lookup<NativeFunction<PlayAudioFunc>>('play_audio')
      .asFunction();

  /// Calls the Rust play_audio function.
  static void playAudio(String track) {
    final trackPtr = track.toNativeUtf8();
    _playAudio(trackPtr);
    malloc.free(trackPtr);
  }
}
