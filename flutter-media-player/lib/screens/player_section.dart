// lib/screens/player_section.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../services/player_model.dart';
import '../services/playlist_repository.dart';

class PlayerSection extends StatefulWidget {
  const PlayerSection({super.key});

  @override
  State<PlayerSection> createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection> {
  double _volume = 0.75;
  bool _muted = false;
  bool _shuffle = false;
  String? _albumArtPath;

  @override
  void initState() {
    super.initState();
    final player = context.read<PlayerModel>();
    player.addListener(_onTrackChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTrackChanged());
  }

  @override
  void dispose() {
    context.read<PlayerModel>().removeListener(_onTrackChanged);
    super.dispose();
  }

  void _onTrackChanged() {
    final current = context.read<PlayerModel>().currentPath;
    String? found;
    if (current != null) {
      final dir = File(current).parent;
      try {
        for (var entity in dir.listSync()) {
          if (entity is File) {
            final lower = entity.path.toLowerCase();
            if (lower.endsWith('.jpg') ||
                lower.endsWith('.png') ||
                lower.endsWith('.jpeg')) {
              found = entity.path;
              break;
            }
          }
        }
      } catch (_) {}
    }
    setState(() => _albumArtPath = found);
  }

  Future<void> _prevTrack() async {
    final repo = context.read<PlaylistRepository>();
    final player = context.read<PlayerModel>();
    final playlistId = repo.selectedPlaylistId;
    if (playlistId == null) return;
    final playlist = repo.playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => Playlist(id: '', name: ''),
    );
    final songs = playlist.songPaths;
    final current = player.currentPath;
    final idx = current != null ? songs.indexOf(current) : -1;
    if (idx > 0) {
      await player.stop();
      await player.play(songs[idx - 1]);
    }
  }

  Future<void> _nextTrack() async {
    final repo = context.read<PlaylistRepository>();
    final player = context.read<PlayerModel>();
    final playlistId = repo.selectedPlaylistId;
    if (playlistId == null) return;
    final playlist = repo.playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => Playlist(id: '', name: ''),
    );
    final songs = playlist.songPaths;
    final current = player.currentPath;
    final idx = current != null ? songs.indexOf(current) : -1;
    if (idx >= 0 && idx < songs.length - 1) {
      await player.stop();
      await player.play(songs[idx + 1]);
    }
  }

  void _rewind10()  => context.read<PlayerModel>().seekRelative(-10);
  void _forward10() => context.read<PlayerModel>().seekRelative(10);
  void _toggleShuffle() => setState(() => _shuffle = !_shuffle);

  String get _speakerAsset {
    if (_muted) return 'assets/icons/ph--speaker-x-fill.svg';
    if (_volume == 0) return 'assets/icons/ph--speaker-slash-fill.svg';
    if (_volume <= 0.25) return 'assets/icons/ph--speaker-none-fill.svg';
    if (_volume <= 0.5) return 'assets/icons/ph--speaker-low-fill.svg';
    return 'assets/icons/ph--speaker-high-fill.svg';
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    final newVol = _muted ? 0.0 : _volume;
    context.read<PlayerModel>().setVolume(newVol);
  }

  void _onVolumeChanged(double v) {
    setState(() {
      _volume = v;
      if (v > 0) _muted = false;
    });
    context.read<PlayerModel>().setVolume(v);
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerModel>();
    final brightGreen = const Color(0xFF00FF00);
    final darkGreen   = brightGreen.withAlpha((0.4 * 255).round());
    final bgColor     = const Color(0xFF151515);

    final playIcon = player.isPlaying
        ? 'assets/icons/ph--pause-circle-bold.svg'
        : 'assets/icons/ph--play-circle-bold.svg';

    String titleText = player.currentPath != null
        ? File(player.currentPath!).uri.pathSegments.last
        : 'Media Player';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: darkGreen, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Album art or placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              border: Border.all(color: darkGreen, width: 2),
            ),
            child: _albumArtPath != null
                ? Image.file(File(_albumArtPath!), fit: BoxFit.cover)
                : Center(
                    child: SvgPicture.asset(
                      'assets/icons/ph--music-notes-fill.svg',
                      color: brightGreen.withAlpha((0.5 * 255).round()),
                      width: 32,
                      height: 32,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Track title / info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titleText,
                style: TextStyle(
                  color: brightGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Current time
          Text(
            _formatTime(player.position),
            style: TextStyle(color: brightGreen),
          ),
          const SizedBox(width: 8),

          // Seek bar
          Expanded(
            child: Slider(
              activeColor: brightGreen,
              inactiveColor: darkGreen,
              min: 0,
              max: player.duration > 0 ? player.duration : 1,
              value: player.position.clamp(0, player.duration),
              onChanged: (v) => context.read<PlayerModel>().seek(v),
            ),
          ),
          const SizedBox(width: 8),

          // Total duration
          Text(
            _formatTime(player.duration),
            style: TextStyle(color: brightGreen),
          ),
          const SizedBox(width: 24),

          // Prev / rewind / play-pause / forward / next
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--skip-back-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _prevTrack,
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--rewind-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _rewind10,
          ),
          IconButton(
            icon: SvgPicture.asset(
              playIcon,
              color: brightGreen,
              width: 32,
              height: 32,
            ),
            onPressed: () => player.togglePause(),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--fast-forward-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _forward10,
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--skip-forward-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _nextTrack,
          ),

          const SizedBox(width: 16),

          // Shuffle
          IconButton(
            icon: SvgPicture.asset(
              _shuffle
                  ? 'assets/icons/ph--shuffle-bold.svg'
                  : 'assets/icons/ph--shuffle-off-bold.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _toggleShuffle,
          ),

          const SizedBox(width: 24),

          // Mute / Volume controls
          Transform.translate(
            offset: const Offset(8, 0),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
              icon: SvgPicture.asset(
                _speakerAsset,
                color: brightGreen,
                width: 24,
                height: 24,
              ),
              onPressed: _toggleMute,
            ),
          ),
          SizedBox(
            width: 200,
            child: Slider(
              activeColor: brightGreen,
              inactiveColor: darkGreen,
              value: _muted ? 0 : _volume,
              onChanged: _onVolumeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
