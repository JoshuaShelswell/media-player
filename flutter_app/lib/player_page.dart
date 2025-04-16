player\flutter_app\lib\player_page.dart -----
import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

// FFI Type Definitions
typedef _InitNative = Int32 Function();
typedef _OpenNative = Int32 Function(Pointer<Utf8>);
typedef _VoidNative = Void Function();
typedef _GetDoubleNative = Double Function();
typedef _GetUint8Native = Uint8 Function();
typedef _GetStrNative = Pointer<Utf8> Function();

// Native player interface using FFI
class NativePlayer {
  late DynamicLibrary _lib;
  late int Function() _init;
  late int Function(Pointer<Utf8>) _open;
  late void Function() _play;
  late void Function() _pause;
  late void Function() _stop;
  late double Function() _getPosition;
  late double Function() _getDuration;
  late int Function() _getState;
  late Pointer<Utf8> Function() _getTrackTitle;
  late Pointer<Utf8> Function() _getLocalIp;

  NativePlayer() {
    _lib = DynamicLibrary.open('media_player_core.dll');
    _init = _lib.lookupFunction<_InitNative, int Function()>('player_init');
    _open = _lib.lookupFunction<_OpenNative, int Function(Pointer<Utf8>)>('player_open_file');
    _play = _lib.lookupFunction<_VoidNative, void Function()>('player_play');
    _pause = _lib.lookupFunction<_VoidNative, void Function()>('player_pause');
    _stop = _lib.lookupFunction<_VoidNative, void Function()>('player_stop');
    _getPosition = _lib.lookupFunction<_GetDoubleNative, double Function()>('player_get_position');
    _getDuration = _lib.lookupFunction<_GetDoubleNative, double Function()>('player_get_duration');
    _getState = _lib.lookupFunction<_GetUint8Native, int Function()>('player_get_state');
    _getTrackTitle = _lib.lookupFunction<_GetStrNative, Pointer<Utf8> Function()>('player_get_track_title');
    _getLocalIp = _lib.lookupFunction<_GetStrNative, Pointer<Utf8> Function()>('player_get_local_ip');
  }

  bool init() => _init() != 0;
  bool openFile(String path) {
    final cPath = path.toNativeUtf8();
    int result = _open(cPath);
    malloc.free(cPath);
    return result != 0;
  }

  void play() => _play();
  void pause() => _pause();
  void stop() => _stop();
  double getPosition() => _getPosition();
  double getDuration() => _getDuration();
  int getState() => _getState();
  String getTrackTitle() {
    Pointer<Utf8> ptr = _getTrackTitle();
    return ptr.address != 0 ? ptr.toDartString() : "";
  }

  String getLocalIp() {
    Pointer<Utf8> ptr = _getLocalIp();
    return ptr.address != 0 ? ptr.toDartString() : "";
  }
}

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late NativePlayer _native;
  bool _initialized = false;
  int _state = 0; // 0=stopped, 1=playing, 2=paused
  String _trackTitle = "";
  double _duration = 0.0;
  double _position = 0.0;
  String _localIp = "";
  Timer? _pollTimer;

  static const int STATE_STOPPED = 0;
  static const int STATE_PLAYING = 1;
  static const int STATE_PAUSED = 2;

  @override
  void initState() {
    super.initState();
    _native = NativePlayer();
    _initialized = _native.init();
    if (_initialized) {
      _localIp = _native.getLocalIp();
      if (_localIp.isEmpty) _localIp = "Unknown";
      _pollTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateStatus());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _updateStatus() {
    int state = _native.getState();
    double pos = (state != STATE_STOPPED) ? _native.getPosition() : 0.0;
    setState(() {
      _state = state;
      _position = pos;
      if (_state == STATE_STOPPED) {
        _trackTitle = "";
        _duration = 0.0;
      } else {
        _duration = _native.getDuration();
        if (_trackTitle.isEmpty) {
          _trackTitle = _native.getTrackTitle();
        }
      }
    });
  }

  void _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      bool ok = _native.openFile(filePath);
      if (ok) {
        setState(() {
          _trackTitle = _native.getTrackTitle();
          _duration = _native.getDuration();
          _position = 0.0;
          _state = STATE_PLAYING;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file'))
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_state == STATE_PLAYING) {
      _native.pause();
      setState(() { _state = STATE_PAUSED; });
    } else if (_state == STATE_PAUSED) {
      _native.play();
      setState(() { _state = STATE_PLAYING; });
    }
  }

  void _stopPlayback() {
    _native.stop();
    setState(() {
      _state = STATE_STOPPED;
      _trackTitle = "";
      _duration = 0.0;
      _position = 0.0;
    });
  }

  String _formatTime(double seconds) {
    int totalSec = seconds.floor();
    int minutes = totalSec ~/ 60;
    int sec = totalSec % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Media Player')),
        body: Center(child: Text('Initialization failed')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Media Player')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _trackTitle.isEmpty ? 'No track loaded' : _trackTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            if (_state != STATE_STOPPED) ...[
              Slider(
                value: (_duration > 0) ? _position.clamp(0.0, _duration) : 0.0,
                max: (_duration > 0) ? _duration : 1.0,
                onChanged: null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatTime(_position)),
                  Text(_formatTime(_duration)),
                ],
              ),
            ] else
              SizedBox(height: 48),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.folder_open),
                  iconSize: 48,
                  onPressed: _openFile,
                  tooltip: 'Open File',
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(_state == STATE_PLAYING ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  iconSize: 64,
                  onPressed: (_state == STATE_STOPPED) ? null : _togglePlayPause,
                  tooltip: _state == STATE_PLAYING ? 'Pause' : 'Play',
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 48,
                  onPressed: (_state != STATE_STOPPED) ? _stopPlayback : null,
                  tooltip: 'Stop',
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Remote Control: ws://${_localIp}:3000',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}