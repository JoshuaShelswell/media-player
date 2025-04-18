// lib/screens/playing_section.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';

import '../services/playlist_repository.dart';
import '../services/player_model.dart';

class PlayingSection extends StatefulWidget {
  const PlayingSection({Key? key}) : super(key: key);

  @override
  State<PlayingSection> createState() => _PlayingSectionState();
}

class _PlayingSectionState extends State<PlayingSection> {
  List<String> droppedFiles = [];
  int? _hoveredIndex;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    context.read<PlayerModel>().addListener(_onPlaybackUpdate);
  }

  @override
  void dispose() {
    context.read<PlayerModel>().removeListener(_onPlaybackUpdate);
    super.dispose();
  }

  void _onPlaybackUpdate() {
    final model = context.read<PlayerModel>();
    final repo  = context.read<PlaylistRepository>();

    if (_wasPlaying && !model.isPlaying && model.currentPath != null) {
      final pos = model.position;
      final dur = model.duration;
      if (dur > 0 && (pos >= dur - 0.5)) {
        repo.incrementPlayCount(model.currentPath!);
        final pid = repo.selectedPlaylistId;
        if (pid != null) {
          final pl    = repo.playlists.firstWhere((p) => p.id == pid);
          final songs = pl.songPaths;
          final idx   = songs.indexOf(model.currentPath!);
          if (idx >= 0 && idx < songs.length - 1) {
            model.play(songs[idx + 1]);
          }
        }
      }
    }
    _wasPlaying = model.isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    const brightGreen = Color(0xFF00FF00);
    final darkGreen   = brightGreen.withAlpha((0.4 * 255).round());
    const sectionBg   = Color(0xFF151515);

    final repo     = context.watch<PlaylistRepository>();
    final selected = repo.selectedPlaylistId != null
        ? repo.playlists.firstWhere((p) => p.id == repo.selectedPlaylistId)
        : null;
    final songs    = selected?.songPaths ?? droppedFiles;
    final trackCount = songs.length;

    final player  = context.watch<PlayerModel>();
    final current = player.currentPath;

    return DropTarget(
      onDragDone: (details) {
        final paths = details.files.map((f) => f.path).toList();
        if (selected != null && selected.id.isNotEmpty) {
          for (var p in paths) {
            selected.songPaths.add(p);
            selected.playCounts[p] = 0;
          }
          repo.savePlaylists();
        } else {
          droppedFiles.addAll(paths);
        }
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: sectionBg,
          border: Border(
            left:  BorderSide(color: darkGreen, width: 2),
            right: BorderSide(color: darkGreen, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dynamic track count
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--music-notes-fill.svg',
                      width: 20,
                      height: 20,
                      color: brightGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Now Playing (tracks $trackCount)',
                      style: const TextStyle(
                        color: brightGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Track list
            Expanded(
              child: songs.isEmpty
                  ? Center(
                      child: Text(
                        'Select a playlist to view songs\nOr drag and drop tracks here',
                        style: TextStyle(color: brightGreen, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, i) {
                        final track     = songs[i];
                        final title     = File(track).uri.pathSegments.last;
                        final isCurrent = track == current;
                        final isHover   = _hoveredIndex == i;
                        final count     = selected?.playCounts[track] ?? 0;

                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoveredIndex = i),
                          onExit:  (_) => setState(() => _hoveredIndex = null),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: isCurrent
                                ? BoxDecoration(
                                    color: brightGreen.withAlpha(
                                        (0.15 * 255).round()),
                                  )
                                : null,
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                          color: brightGreen, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(played $count)',
                                    style: TextStyle(
                                        color: brightGreen.withAlpha(180),
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await context.read<PlayerModel>().stop();
                                await context.read<PlayerModel>().play(track);
                              },
                              trailing: isHover
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          selected!.songPaths.removeAt(i);
                                          repo.savePlaylists();
                                          if (track == current) {
                                            context.read<PlayerModel>().stop();
                                          }
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
