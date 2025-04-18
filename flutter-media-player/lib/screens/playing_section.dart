// lib/screens/playing_section.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';

import '../services/playlist_repository.dart';
import '../services/player_model.dart';

class PlayingSection extends StatefulWidget {
  const PlayingSection({super.key});

  @override
  State<PlayingSection> createState() => _PlayingSectionState();
}

class _PlayingSectionState extends State<PlayingSection> {
  final ScrollController _scrollController = ScrollController();
  int? _hoveredIndex;

  // height of each tile (including its vertical margin)
  static const double _tileExtent = 56.0;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerModel>();
    player.addListener(_scrollToCurrent);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void dispose() {
    context.read<PlayerModel>().removeListener(_scrollToCurrent);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrent() {
    final repo   = context.read<PlaylistRepository>();
    final player = context.read<PlayerModel>();
    final pid    = repo.selectedPlaylistId;
    if (pid == null) return;

    final pl     = repo.playlists.firstWhere((p) => p.id == pid);
    final songs  = pl.songPaths;
    final current = player.currentPath;
    if (current == null) return;

    final idx = songs.indexOf(current);
    if (idx < 0) return;

    _scrollController.animateTo(
      idx * _tileExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const brightGreen = Color(0xFF00FF00);
    final darkGreen   = brightGreen.withAlpha((0.4 * 255).round());
    const sectionBg   = Color(0xFF151515);

    final repo = context.watch<PlaylistRepository>();
    final pid  = repo.selectedPlaylistId;
    final pl   = pid != null
        ? repo.playlists.firstWhere((p) => p.id == pid)
        : null;
    final songs  = pl?.songPaths ?? [];

    final player  = context.watch<PlayerModel>();
    final current = player.currentPath;

    return DropTarget(
      onDragDone: (details) {
        final paths = details.files.map((f) => f.path).toList();
        if (pl != null) {
          pl.songPaths.addAll(paths);
          repo.savePlaylists();
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
            // Header
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--music-notes-fill.svg',
                      width: 20, height: 20, color: brightGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Now Playing (tracks ${songs.length})',
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

            const SizedBox(height: 8),

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
                      controller: _scrollController,
                      itemCount: songs.length,
                      itemExtent: _tileExtent,
                      itemBuilder: (context, i) {
                        final track     = songs[i];
                        final title     = File(track).uri.pathSegments.last;
                        final isCurrent = track == current;
                        final isHover   = _hoveredIndex == i;
                        final played    = pl?.playCounts[track] ?? 0;

                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _hoveredIndex = i),
                          onExit:  (_) => setState(() => _hoveredIndex = null),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: isCurrent
                                ? BoxDecoration(
                                    color: brightGreen.withAlpha(38),
                                  )
                                : null,
                            child: ListTile(
                              dense: true,
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(color: brightGreen),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(played $played)',
                                    style: TextStyle(
                                        color: brightGreen, fontSize: 12),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                // Avoid using `context` after an await:
                                final playerModel = context.read<PlayerModel>();
                                await playerModel.stop();
                                if (!mounted) return;
                                await playerModel.play(track);
                              },
                              trailing: isHover
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          pl!.songPaths.removeAt(i);
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
