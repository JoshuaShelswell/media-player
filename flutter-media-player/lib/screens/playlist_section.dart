import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/playlist_repository.dart';

class PlaylistSection extends StatefulWidget {
  const PlaylistSection({super.key});

  @override
  State<PlaylistSection> createState() => _PlaylistSectionState();
}

class _PlaylistSectionState extends State<PlaylistSection> {
  final TextEditingController _playlistController = TextEditingController();

  static const Color brightGreen = Color(0xFF00FF00);
  late final Color darkGreen = brightGreen.withAlpha((0.4 * 255).round());
  static const Color sectionBg = Color(0xFF151515);

  @override
  void dispose() {
    _playlistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: sectionBg,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--files-fill.svg',
                      width: 20,
                      height: 20,
                      color: brightGreen,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Playlists',
                      style: TextStyle(
                        color: brightGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: brightGreen,
                  onPressed: () async {
                    // grab repo now, before the async gap
                    final repo = context.read<PlaylistRepository>();

                    final result = await showDialog<String>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        backgroundColor: Colors.black,
                        title: const Text(
                          'Add Playlist',
                          style: TextStyle(color: brightGreen),
                        ),
                        content: TextField(
                          controller: _playlistController,
                          style: const TextStyle(color: brightGreen),
                          decoration: InputDecoration(
                            hintText: 'Playlist name',
                            hintStyle: TextStyle(
                              color: brightGreen.withAlpha(
                                  (0.7 * 255).round()),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: brightGreen),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final name =
                                  _playlistController.text.trim();
                              Navigator.pop(dialogCtx, name);
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(color: brightGreen),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (!mounted) return;
                    if (result != null && result.isNotEmpty) {
                      repo.addPlaylist(result);
                      _playlistController.clear();
                    }
                  },
                ),
              ],
            ),
          ),

          // Playlist list
          Expanded(
            child: Consumer<PlaylistRepository>(
              builder: (context, repo, _) {
                return ListView.builder(
                  itemCount: repo.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = repo.playlists[index];
                    final isSelected =
                        repo.selectedPlaylistId == playlist.id;
                    return _PlaylistTile(
                      playlist: playlist,
                      selected: isSelected,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatefulWidget {
  final Playlist playlist;
  final bool selected;

  const _PlaylistTile({
    required this.playlist,
    required this.selected,
  });

  @override
  State<_PlaylistTile> createState() => __PlaylistTileState();
}

class __PlaylistTileState extends State<_PlaylistTile> {
  bool _hovering = false;
  static const Color brightGreen = Color(0xFF00FF00);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: widget.selected
            ? BoxDecoration(
                color:
                    brightGreen.withAlpha((0.15 * 255).round()),
              )
            : null,
        child: ListTile(
          title: Text(
            widget.playlist.name,
            style: const TextStyle(color: brightGreen),
          ),
          trailing: _hovering
              ? InkWell(
                  onTap: () {
                    // safe to call context here immediately
                    context
                        .read<PlaylistRepository>()
                        .deletePlaylist(widget.playlist.id);
                  },
                  child:
                      const Icon(Icons.close, color: Colors.red, size: 18),
                )
              : null,
          onTap: () {
            context
                .read<PlaylistRepository>()
                .selectPlaylist(widget.playlist.id);
          },
        ),
      ),
    );
  }
}
