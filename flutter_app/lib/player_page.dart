import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'native_player.dart'; // Ensure you have a file named native_player.dart that implements NativePlayer.

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late NativePlayer _native;
  bool _initialized = false;
  int _state = 0; // 0 = stopped, 1 = playing, 2 = paused
  String _trackTitle = "No track selected";
  double _duration = 0.0;
  double _position = 0.0;
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
      // Start a timer to periodically update the playback status.
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateStatus());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _updateStatus() {
    setState(() {
      _state = _native.getState();
      _position = _native.getPosition();
      _duration = _native.getDuration();
      _trackTitle = _native.getTrackTitle();
    });
  }

  Future<void> _openFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      final String filePath = result.files.single.path!;
      final bool success = _native.openFile(filePath);
      if (success) {
        // If file opening is successful, start playback.
        _native.play();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open file')),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_state == STATE_PLAYING) {
      _native.pause();
    } else if (_state == STATE_PAUSED || _state == STATE_STOPPED) {
      _native.play();
    }
  }

  void _stopPlayback() {
    _native.stop();
  }

  String _formatTime(double seconds) {
    final int totalSec = seconds.floor();
    final int minutes = totalSec ~/ 60;
    final int sec = totalSec % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Media Player')),
        body: const Center(child: Text('Initialization failed')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Media Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _trackTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Slider(
              value: (_duration > 0) ? _position.clamp(0.0, _duration) : 0.0,
              max: (_duration > 0) ? _duration : 1.0,
              onChanged: (value) {
                // You can add code here to allow seeking if needed.
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position)),
                Text(_formatTime(_duration)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  iconSize: 48,
                  onPressed: _openFile,
                  tooltip: 'Open File',
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(_state == STATE_PLAYING ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  iconSize: 64,
                  onPressed: (_state == STATE_STOPPED) ? null : _togglePlayPause,
                  tooltip: _state == STATE_PLAYING ? 'Pause' : 'Play',
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.stop),
                  iconSize: 48,
                  onPressed: (_state != STATE_STOPPED) ? _stopPlayback : null,
                  tooltip: 'Stop',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
