// media-player-project/flutter-media-player/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/player_screen.dart';

void main() {
  runApp(FlutterMediaPlayerApp());
}

class FlutterMediaPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Media Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlayerScreen(),
    );
  }
}
