import 'package:flutter/material.dart';
import 'remote_page.dart';

void main() {
  runApp(RemoteApp());
}

class RemoteApp extends StatelessWidget {
  const RemoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Player Remote',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      home: RemotePage(),
    );
  }
}