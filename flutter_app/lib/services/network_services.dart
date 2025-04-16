// flutter_app/lib/services/network_service.dart
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI signatures
typedef StartRemoteServerFunc = Bool Function(Int32 port);

class NetworkService {
  late DynamicLibrary _nativeLib;
  late StartRemoteServerFunc _startRemoteServer;
  
  Future<void> initialize() async {
    // Load the native library (same as in PlayerService)
    if (Platform.isWindows) {
      _nativeLib = DynamicLibrary.open('rust_core.dll');
    } else if (Platform.isLinux) {
      _nativeLib = DynamicLibrary.open('librust_core.so');
    } else if (Platform.isMacOS) {
      _nativeLib = DynamicLibrary.open('librust_core.dylib');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    
    // Initialize FFI functions
    _startRemoteServer = _nativeLib
        .lookupFunction<StartRemoteServerFunc, StartRemoteServerFunc>('start_remote_server');
  }
  
  Future<bool> startServer(int port) async {
    return _startRemoteServer(port);
  }
}