import 'dart:io';
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
  List<String> _dropped = [];

  @override
  Widget build(BuildContext context) {
    final Color brightGreen = const Color(0xFF00FF00);
    final Color darkGreen = brightGreen.withOpacity(0.4);
    final Color sectionBg = const Color(0xFF151515);

    return Consumer<PlaylistRepository>(
      builder: (ctx, repo, _) {
        final pl = repo.selectedPlaylistId == null
            ? null
            : repo.playlists.firstWhere(
                (p) => p.id == repo.selectedPlaylistId,
                orElse: () => Playlist(id: '', name: ''),
              );
        final songs = (pl != null && pl.id.isNotEmpty)
            ? pl.songPaths
            : _dropped;

        return DropTarget(
          onDragDone: (d) {
            final paths = d.files.map((f) => f.path).toList();
            setState(() {
              if (pl != null && pl.id.isNotEmpty) {
                pl.songPaths.addAll(paths);
                repo.savePlaylists();
              } else {
                _dropped.addAll(paths);
              }
            });
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: sectionBg,
              border: Border.symmetric(
                vertical: BorderSide(color: darkGreen, width: 2),
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
                Expanded(
                  child: songs.isEmpty
                      ? Center(
                          child: Text(
                            'Drop tracks here or select a playlist',
                            style: TextStyle(color: brightGreen),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (_, i) {
                            final playing = i == 0;
                            return _SongTile(
                              path: songs[i],
                              playing: playing,
                              onRemove: () {
                                setState(() {
                                  songs.removeAt(i);
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
  final String path;
  final bool playing;
  final VoidCallback onRemove;
  const _SongTile({
    Key? key,
    required this.path,
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
      child: ListTile(
        tileColor: widget.playing
            ? brightGreen.withOpacity(0.2)
            : Colors.transparent,
        title: Text(
          widget.path.split(Platform.pathSeparator).last,
          style: TextStyle(color: brightGreen),
        ),
        trailing: _hover
            ? IconButton(
                icon: Icon(Icons.close, color: Colors.red, size: 18),
                onPressed: widget.onRemove,
              )
            : null,
      ),
    );
  }
}
