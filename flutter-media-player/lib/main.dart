import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/media_player_screen.dart';
import 'services/playlist_repository.dart';

void main() {
  runApp(const MyMediaPlayerApp());
}

class MyMediaPlayerApp extends StatelessWidget {
  const MyMediaPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlaylistRepository>(
      create: (_) => PlaylistRepository(),
      child: MaterialApp(
        title: 'Media Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const MediaPlayerScreen(),
      ),
    );
  }
}
