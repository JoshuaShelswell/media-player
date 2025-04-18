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

  @override
  Widget build(BuildContext context) {
    const Color brightGreen = Color(0xFF00FF00);
    final Color darkGreen = brightGreen.withAlpha((0.4 * 255).round());
    const Color sectionBg = Color(0xFF151515);

    final repo = context.watch<PlaylistRepository>();
    final selected = repo.selectedPlaylistId != null
        ? repo.playlists.firstWhere(
            (p) => p.id == repo.selectedPlaylistId,
            orElse: () => Playlist(id: '', name: ''),
          )
        : null;
    final songs = selected?.songPaths ?? [];

    final player = context.watch<PlayerModel>();
    final current = player.currentPath;

    return DropTarget(
      onDragDone: (details) {
        final paths = details.files.map((f) => f.path).toList();
        setState(() {
          if (selected != null && selected.id.isNotEmpty) {
            selected.songPaths.addAll(paths);
            repo.savePlaylists();
          } else {
            droppedFiles.addAll(paths);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: sectionBg,
          border: Border(
            left: BorderSide(color: darkGreen, width: 2),
            right: BorderSide(color: darkGreen, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (10px inset, 48px tall)
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--music-notes-fill.svg',
                      width: 20,
                      height: 20,
                      color: brightGreen,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Now Playing',
                      style: TextStyle(
                        color: brightGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TRACK LIST
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
                      itemBuilder: (context, i) {
                        final track = songs.isNotEmpty
                            ? songs[i]
                            : droppedFiles[i];
                        final title = File(track).uri.pathSegments.last;
                        final isCurrent = track == current;
                        final isHover = _hoveredIndex == i;

                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredIndex = i),
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: isCurrent
                                ? BoxDecoration(
                                    color: brightGreen
                                        .withAlpha((0.15 * 255).round()),
                                  )
                                : null,
                            child: ListTile(
                              title: Text(
                                title,
                                style: TextStyle(color: brightGreen),
                              ),
                              onTap: () =>
                                  context.read<PlayerModel>().play(track),
                              trailing: isHover
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (songs.isNotEmpty) {
                                            selected!.songPaths.removeAt(i);
                                            repo.savePlaylists();
                                            if (track == current) {
                                              context
                                                  .read<PlayerModel>()
                                                  .stop();
                                            }
                                          } else {
                                            droppedFiles.removeAt(i);
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
