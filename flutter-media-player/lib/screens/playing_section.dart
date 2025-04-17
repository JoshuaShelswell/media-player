// lib/screens/playing_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../services/playlist_repository.dart';
import '../services/audio_player.dart'; // ← NEW

class PlayingSection extends StatefulWidget {
  const PlayingSection({Key? key}) : super(key: key);

  @override
  _PlayingSectionState createState() => _PlayingSectionState();
}

class _PlayingSectionState extends State<PlayingSection> {
  List<String> droppedFiles = [];

  @override
  Widget build(BuildContext context) {
    final Color brightGreen = const Color(0xFF00FF00);
    final Color darkGreen   = brightGreen.withOpacity(0.4);
    final Color sectionBg   = const Color(0xFF151515);

    return Consumer<PlaylistRepository>(
      builder: (context, repo, _) {
        final selected = repo.selectedPlaylistId != null
            ? repo.playlists.firstWhere(
                (p) => p.id == repo.selectedPlaylistId,
                orElse: () => Playlist(id: '', name: ''))
            : null;
        final songs = selected?.songPaths ?? [];

        return DropTarget(
          onDragDone: (d) {
            final paths = d.files.map((f) => f.path).toList();
            setState(() {
              if (selected != null && selected.id.isNotEmpty) {
                selected.songPaths.addAll(paths);
                repo.notifyListeners();
                repo.savePlaylists();
              } else {
                droppedFiles.addAll(paths);
              }
            });
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: sectionBg,
              border: Border(
                left:  BorderSide(color: darkGreen, width: 2),
                right: BorderSide(color: darkGreen, width: 2),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--music-notes-fill.svg',
                      width: 20,
                      height: 20,
                      color: brightGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        color: brightGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: (songs.isEmpty && droppedFiles.isEmpty)
                      ? Center(
                          child: Text(
                            'Select a playlist to view songs\nOr drag and drop tracks here',
                            style: TextStyle(color: brightGreen, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: songs.isNotEmpty
                              ? songs.length
                              : droppedFiles.length,
                          itemBuilder: (ctx, i) {
                            final track = songs.isNotEmpty
                                ? songs[i]
                                : droppedFiles[i];
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ListTile(
                                title: Text(
                                  track,
                                  style: TextStyle(color: brightGreen),
                                ),
                                onTap: () {
                                  // ← CALL INTO RUST
                                  AudioPlayer.play(track);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
