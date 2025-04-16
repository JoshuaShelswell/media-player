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

  final Color brightGreen = const Color(0xFF00FF00);
  late final Color darkGreen = brightGreen.withOpacity(0.4);
  // Use the same background as PlayerSection and PlayingSection.
  final Color sectionBg = const Color(0xFF151515);

  @override
  void dispose() {
    _playlistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        // No right border here.
        border: Border(
          // You can add a left border if desired:
          // left: BorderSide(color: darkGreen, width: 2),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playlists',
                  style: TextStyle(
                    color: brightGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ph--folder-plus-fill.svg',
                    width: 20,
                    height: 20,
                    color: brightGreen,
                  ),
                  onPressed: () async {
                    final result = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.black,
                          title: Text('Add Playlist', style: TextStyle(color: brightGreen)),
                          content: TextField(
                            controller: _playlistController,
                            style: TextStyle(color: brightGreen),
                            decoration: InputDecoration(
                              hintText: 'Playlist name',
                              hintStyle: TextStyle(color: brightGreen.withOpacity(0.7)),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: TextStyle(color: brightGreen)),
                            ),
                            TextButton(
                              onPressed: () {
                                final name = _playlistController.text.trim();
                                Navigator.pop(context, name);
                              },
                              child: Text('Add', style: TextStyle(color: brightGreen)),
                            ),
                          ],
                        );
                      },
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
          Expanded(
            child: Consumer<PlaylistRepository>(
              builder: (context, repo, child) {
                return ListView.builder(
                  itemCount: repo.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = repo.playlists[index];
                    final isSelected = repo.selectedPlaylistId == playlist.id;
                    return _PlaylistTile(playlist: playlist, selected: isSelected);
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

  @override
  Widget build(BuildContext context) {
    final Color brightGreen = const Color(0xFF00FF00);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: ListTile(
        tileColor: widget.selected ? brightGreen.withOpacity(0.2) : Colors.transparent,
        title: Text(
          widget.playlist.name,
          style: TextStyle(color: brightGreen),
        ),
        trailing: _hovering
            ? InkWell(
                onTap: () {
                  Provider.of<PlaylistRepository>(context, listen: false)
                      .deletePlaylist(widget.playlist.id);
                },
                child: Icon(Icons.close, color: brightGreen),
              )
            : null,
        onTap: () {
          Provider.of<PlaylistRepository>(context, listen: false)
              .selectPlaylist(widget.playlist.id);
        },
      ),
    );
  }
}
