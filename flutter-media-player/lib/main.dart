// lib/main.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/media_player_screen.dart';
import 'services/playlist_repository.dart';
import 'services/player_model.dart';
import 'services/audio_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize window_manager
  await windowManager.ensureInitialized();

  // 2. Intercept the close button instead of letting it kill just the window
  await windowManager.setPreventClose(true);

  // 3. Restore the last position
  final prefs = await SharedPreferences.getInstance();
  final dx = prefs.getDouble('windowPosX') ?? 100.0;
  final dy = prefs.getDouble('windowPosY') ?? 100.0;
  await windowManager.setPosition(Offset(dx, dy));

  // 4. Listen for our custom close logic
  windowManager.addListener(_MyWindowCloseListener());

  runApp(const MyMediaPlayerApp());
}

class _MyWindowCloseListener extends WindowListener {
  @override
  Future<void> onWindowClose() async {
    // confirm we actually want to intercept
    if (await windowManager.isPreventClose()) {
      // a) save window position
      final pos = await windowManager.getPosition();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('windowPosX', pos.dx);
      await prefs.setDouble('windowPosY', pos.dy);

      // b) stop any playing audio / FFmpeg isolate
      await AudioPlayer.instance.stop();

      // c) destroy the window
      await windowManager.destroy();

      // d) exit the process completely
      exit(0);
    }
  }
}

class MyMediaPlayerApp extends StatelessWidget {
  const MyMediaPlayerApp({super.key});

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
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const MediaPlayerScreen(),
      ),
    );
  }
}
