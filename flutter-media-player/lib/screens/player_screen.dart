// media-player-project/flutter-media-player/lib/screens/player_screen.dart
import 'package:flutter/material.dart';
import '../services/rust_bridge.dart';

class PlayerScreen extends StatefulWidget {
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _trackController = TextEditingController();

  void _playTrack() {
    final track = _trackController.text;
    if (track.isNotEmpty) {
      RustBridge.playAudio(track);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _trackController,
              decoration: InputDecoration(labelText: 'Enter track name/path'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(onPressed: _playTrack, child: Text('Play Track')),
          ],
        ),
      ),
    );
  }
}
