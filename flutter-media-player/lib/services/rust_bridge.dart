import 'dart:ffi';
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

typedef PlayAudioFileFunc = Int32 Function(Pointer<Utf8>);
typedef PlayAudioFile = int Function(Pointer<Utf8>);

class RustBridge {
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

  static final PlayAudioFile _playAudioFile = _dylib
      .lookup<NativeFunction<PlayAudioFileFunc>>('play_audio_file_ffi')
      .asFunction();

  static int playAudioFile(String filePath) {
    final ptr = filePath.toNativeUtf8();
    final result = _playAudioFile(ptr);
    malloc.free(ptr);
    return result;
  }
}
