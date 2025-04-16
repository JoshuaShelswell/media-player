import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';
import '../services/playlist_repository.dart';

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
    final Color darkGreen = brightGreen.withOpacity(0.4);
    final Color sectionBg = const Color(0xFF151515);

    return Consumer<PlaylistRepository>(
      builder: (context, repo, _) {
        final selected = repo.selectedPlaylistId != null
            ? repo.playlists.firstWhere(
                (p) => p.id == repo.selectedPlaylistId,
                orElse: () => Playlist(id: '', name: ''),
              )
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
                left: BorderSide(color: darkGreen, width: 2),
                right: BorderSide(color: darkGreen, width: 2),
              ),
            ),
            // ↑ bump top padding from 10 to 20 to align header vertically
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            final isPlaying = i == 0;
                            return _SongTile(
                              track: track,
                              playing: isPlaying,
                              onRemove: () {
                                setState(() {
                                  if (songs.isNotEmpty) {
                                    selected!.songPaths.removeAt(i);
                                  } else {
                                    droppedFiles.removeAt(i);
                                  }
                                  repo.savePlaylists();
                                });
                              },
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

class _SongTile extends StatefulWidget {
  final String track;
  final bool playing;
  final VoidCallback onRemove;
  const _SongTile({
    Key? key,
    required this.track,
    required this.playing,
    required this.onRemove,
  }) : super(key: key);

  @override
  __SongTileState createState() => __SongTileState();
}

class __SongTileState extends State<_SongTile> {
  bool _hover = false;
  final Color brightGreen = const Color(0xFF00FF00);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: widget.playing
            ? BoxDecoration(color: brightGreen.withOpacity(0.15))
            : null,
        child: ListTile(
          title: Text(widget.track, style: TextStyle(color: brightGreen)),
          trailing: _hover
              ? InkWell(
                  onTap: widget.onRemove,
                  child: Icon(Icons.close, color: Colors.red, size: 18),
                )
              : null,
        ),
      ),
    );
  }
}
