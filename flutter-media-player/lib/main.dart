import 'package:flutter/material.dart';
import 'screens/media_player_screen.dart';

void main() {
  runApp(MyMediaPlayerApp());
}

class MyMediaPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Player',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green,
        // Update text theme to use Flutter's new naming
        textTheme: ThemeData.dark().textTheme.copyWith(
          bodyMedium: TextStyle(color: Color(0xFF00FF00)), // neon green
          headlineMedium: TextStyle(color: Color(0xFF00FF00)),
        ),
      ),
      home: MediaPlayerScreen(),
    );
  }
}
