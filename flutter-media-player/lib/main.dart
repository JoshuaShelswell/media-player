import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/media_player_screen.dart';
import 'services/playlist_repository.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window_manager.
  await windowManager.ensureInitialized();

  // Load saved window position.
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final double posX = prefs.getDouble('windowPosX') ?? 100.0;
  final double posY = prefs.getDouble('windowPosY') ?? 100.0;
  await windowManager.setPosition(Offset(posX, posY));

  // Add our listener to capture window events.
  windowManager.addListener(MyWindowListener());

  runApp(const MyMediaPlayerApp());
}

class MyWindowListener extends WindowListener {
  // Save window position on close event.
  @override
  void onWindowClose() async {
    final pos = await windowManager.getPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('windowPosX', pos.dx);
    await prefs.setDouble('windowPosY', pos.dy);
  }

  // We'll also continue to poll periodically in case moves are not caught.
  @override
  void onWindowMove() async {
    final pos = await windowManager.getPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('windowPosX', pos.dx);
    await prefs.setDouble('windowPosY', pos.dy);
  }
}

class MyMediaPlayerApp extends StatefulWidget {
  const MyMediaPlayerApp({Key? key}) : super(key: key);

  @override
  _MyMediaPlayerAppState createState() => _MyMediaPlayerAppState();
}

class _MyMediaPlayerAppState extends State<MyMediaPlayerApp> with WindowListener {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Optionally, add the window listener here again if needed.
    windowManager.addListener(this);
    // Start a periodic timer to poll the window position every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final Offset pos = await windowManager.getPosition();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('windowPosX', pos.dx);
      await prefs.setDouble('windowPosY', pos.dy);
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
    return ChangeNotifierProvider<PlaylistRepository>(
      create: (_) => PlaylistRepository(),
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
