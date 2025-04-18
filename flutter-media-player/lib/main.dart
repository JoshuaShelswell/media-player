// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/media_player_screen.dart';
import 'services/playlist_repository.dart';
import 'services/player_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Restore window position
  final prefs = await SharedPreferences.getInstance();
  final posX = prefs.getDouble('windowPosX') ?? 100.0;
  final posY = prefs.getDouble('windowPosY') ?? 100.0;
  await windowManager.setPosition(Offset(posX, posY));
  windowManager.addListener(MyWindowListener());

  runApp(const MyMediaPlayerApp());
}

class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    final p = await windowManager.getPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('windowPosX', p.dx);
    await prefs.setDouble('windowPosY', p.dy);
  }

  @override
  void onWindowMove() async {
    final p = await windowManager.getPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('windowPosX', p.dx);
    await prefs.setDouble('windowPosY', p.dy);
  }
}

class MyMediaPlayerApp extends StatefulWidget {
  const MyMediaPlayerApp({super.key});
  @override
  State<MyMediaPlayerApp> createState() => _MyMediaPlayerAppState();
}

class _MyMediaPlayerAppState extends State<MyMediaPlayerApp>
    with WindowListener {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // Periodically save window position
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final p = await windowManager.getPosition();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('windowPosX', p.dx);
      await prefs.setDouble('windowPosY', p.dy);
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaylistRepository()),
        ChangeNotifierProvider(create: (_) => PlayerModel()),
      ],
      child: MaterialApp(
        title: 'Amped',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
        home: const MediaPlayerScreen(),
      ),
    );
  }
}
