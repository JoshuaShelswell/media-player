import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../services/playlist_repository.dart';

class PlayingSection extends StatefulWidget {
  const PlayingSection({Key? key}) : super(key: key);

  @override
  _PlayingSectionState createState() => _PlayingSectionState();
}

class _PlayingSectionState extends State<PlayingSection> {
  // For demonstration, maintain a local list of dropped file paths.
  List<String> droppedFiles = [];

  @override
  Widget build(BuildContext context) {
    final Color brightGreen = const Color(0xFF00FF00);
    final Color darkGreen = brightGreen.withOpacity(0.4);
    final Color sectionBg = const Color(0xFF151515);

    return Consumer<PlaylistRepository>(
      builder: (context, repo, child) {
        final Playlist? selectedPlaylist = repo.selectedPlaylistId != null
            ? repo.playlists.firstWhere(
                (p) => p.id == repo.selectedPlaylistId,
                orElse: () => Playlist(id: '', name: ''))
            : null;
        final List<String> songs = selectedPlaylist?.songPaths ?? [];

        return DropTarget(
          onDragDone: (detail) {
            // When files are dropped, add their paths to the selected playlist.
            setState(() {
              final files = detail.files.map((file) => file.path).toList();
              if (selectedPlaylist != null && selectedPlaylist.id.isNotEmpty) {
                selectedPlaylist.songPaths.addAll(files);
                repo.notifyListeners();
                repo.savePlaylists();
              } else {
                // For demonstration, store files locally if no playlist is selected.
                droppedFiles.addAll(files);
              }
            });
          },
          onDragEntered: (detail) {
            // Optionally update UI when dragging enters.
          },
          onDragExited: (detail) {
            // Optionally update UI when dragging exits.
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: sectionBg,
              // Vertical borders on left and right only.
              border: Border(
                left: BorderSide(color: darkGreen, width: 2),
                right: BorderSide(color: darkGreen, width: 2),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now Playing',
                  style: TextStyle(
                    color: brightGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if ((selectedPlaylist == null || selectedPlaylist.id.isEmpty) &&
                    droppedFiles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Select a playlist to view songs\nOr drag and drop tracks here',
                        style: TextStyle(color: brightGreen, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: songs.isNotEmpty ? songs.length : droppedFiles.length,
                      itemBuilder: (context, index) {
                        final String song =
                            songs.isNotEmpty ? songs[index] : droppedFiles[index];
                        // For demonstration purposes, assume the first song is playing.
                        final bool isSongPlaying = index == 0;
                        return ListTile(
                          tileColor: isSongPlaying
                              ? brightGreen.withOpacity(0.2)
                              : Colors.transparent,
                          title: Text(
                            song,
                            style: TextStyle(color: brightGreen),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.close, color: brightGreen, size: 20),
                            onPressed: () {
                              setState(() {
                                if (songs.isNotEmpty) {
                                  selectedPlaylist!.songPaths.removeAt(index);
                                } else {
                                  droppedFiles.removeAt(index);
                                }
                              });
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
