import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/playlist_repository.dart';

class PlaylistSection extends StatefulWidget {
  const PlaylistSection({Key? key}) : super(key: key);

  @override
  _PlaylistSectionState createState() => _PlaylistSectionState();
}

class _PlaylistSectionState extends State<PlaylistSection> {
  final TextEditingController _playlistController = TextEditingController();

  static const Color brightGreen = Color(0xFF00FF00);
  late final Color darkGreen = brightGreen.withOpacity(0.4);
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
                    final result = await showDialog<String>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.black,
                        title: const Text('Add Playlist',
                            style: TextStyle(color: brightGreen)),
                        content: TextField(
                          controller: _playlistController,
                          style: const TextStyle(color: brightGreen),
                          decoration: InputDecoration(
                            hintText: 'Playlist name',
                            hintStyle:
                                TextStyle(color: brightGreen.withOpacity(0.7)),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: brightGreen)),
                          ),
                          TextButton(
                            onPressed: () {
                              final name = _playlistController.text.trim();
                              Navigator.pop(context, name);
                            },
                            child: const Text('Add',
                                style: TextStyle(color: brightGreen)),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      Provider.of<PlaylistRepository>(context, listen: false)
                          .addPlaylist(result);
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
    Key? key,
    required this.playlist,
    required this.selected,
  }) : super(key: key);

  @override
  __PlaylistTileState createState() => __PlaylistTileState();
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
                color: brightGreen.withOpacity(0.15),
              )
            : null,
        child: ListTile(
          title: Text(
            widget.playlist.name,
            style: const TextStyle(color: brightGreen),
          ),
          trailing: _hovering
              ? InkWell(
                  onTap: () => Provider.of<PlaylistRepository>(context,
                          listen: false)
                      .deletePlaylist(widget.playlist.id),
                  child: const Icon(Icons.close,
                      color: Colors.red, size: 18),
                )
              : null,
          onTap: () => Provider.of<PlaylistRepository>(context,
                  listen: false)
              .selectPlaylist(widget.playlist.id),
        ),
      ),
    );
  }
}
