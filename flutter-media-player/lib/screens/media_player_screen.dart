import 'package:flutter/material.dart';
import 'playlist_section.dart';
import 'player_section.dart';
import 'playing_section.dart';
import 'library_section.dart';

class MediaPlayerScreen extends StatelessWidget {
  const MediaPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Outer container with an outer border.
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.green.withOpacity(0.4), width: 2),
        ),
        child: Column(
          children: [
            // Top control area (player controls)
            const PlayerSection(),
            // Main content: playlists on the left, now playing in the middle, library on the right.
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  // Left: PlaylistSection (fixed width)
                  SizedBox(
                    width: 250,
                    child: PlaylistSection(),
                  ),
                  // Middle: PlayingSection (fixed width)
                  SizedBox(
                    width: 350,
                    child: PlayingSection(),
                  ),
                  // Right: LibrarySection (fills remaining space)
                  Expanded(child: LibrarySection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
