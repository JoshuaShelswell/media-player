import 'package:flutter/material.dart';
import 'playlist_section.dart';
import 'playing_section.dart';
import 'player_section.dart';
import 'library_section.dart';

class MediaPlayerScreen extends StatelessWidget {
  const MediaPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // your neon green & dark green
    const brightGreen = Color(0xFF00FF00);
    final borderColor = brightGreen.withOpacity(0.4);

    return Scaffold(
      body: Container(
        // outer black + green border
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            // top: player controls
            const PlayerSection(),

            // main content row
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  // left playlist
                  SizedBox(
                    width: 250,
                    child: PlaylistSection(),
                  ),
                  // center now playing
                  SizedBox(
                    width: 350,
                    child: PlayingSection(),
                  ),
                  // right library fills rest
                  Expanded(
                    child: LibrarySection(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
