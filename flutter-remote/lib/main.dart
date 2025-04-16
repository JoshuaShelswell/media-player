// media-player-project/flutter-remote/lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(FlutterRemoteApp());
}

class FlutterRemoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Remote Control',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: RemoteControlScreen(),
    );
  }
}

class RemoteControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Control'),
      ),
      body: Center(
        child: Text(
          'Remote Control UI Here\n(Implement Bluetooth controls accordingly)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
