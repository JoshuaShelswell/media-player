// lib/screens/player_section.dart

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  bool _repeat = false;
  bool _wasPlaying = false;
  String? _albumArtPath;
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _shuffle = false;
    _repeat = false;
    // Listen both for track/albumArt changes and playback-state changes:
    context.read<PlayerModel>().addListener(_onTrackChanged);
    context.read<PlayerModel>().addListener(_onPlayerState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTrackChanged();
      _onPlayerState();
    });
  }

  @override
  void dispose() {
    context.read<PlayerModel>().removeListener(_onTrackChanged);
    context.read<PlayerModel>().removeListener(_onPlayerState);
    super.dispose();
  }

  /// Update album art when track changes
  void _onTrackChanged() {
    final current = context.read<PlayerModel>().currentPath;
    String? found;
    if (current != null) {
      final dir = File(current).parent;
      for (var f in dir.listSync()) {
        if (f is File && RegExp(r'\.(jpg|png|jpeg)$', caseSensitive: false).hasMatch(f.path)) {
          found = f.path;
          break;
        }
      }
    }
    setState(() => _albumArtPath = found);
  }

  /// Advance or repeat when playback stops after having been playing
  void _onPlayerState() {
    final player = context.read<PlayerModel>();
    // If we were playing, and now are not, it's end-of-track
    if (_wasPlaying && !player.isPlaying) {
      if (_repeat) {
        final cp = player.currentPath;
        if (cp != null) {
          player.play(cp);
        }
      } else {
        _nextTrack();
      }
    }
    _wasPlaying = player.isPlaying;
  }

  Future<void> _prevTrack() async {
    if (_transitioning) return;
    _transitioning = true;
    final repo = context.read<PlaylistRepository>();
    final player = context.read<PlayerModel>();
    final pid = repo.selectedPlaylistId;
    if (pid != null) {
      final pl = repo.playlists.firstWhere((p) => p.id == pid);
      final songs = pl.songPaths;
      if (songs.isNotEmpty) {
        String pick;
        if (_shuffle) {
          final counts = pl.playCounts;
          final minCount = songs.map((s) => counts[s] ?? 0).reduce(min);
          final candidates = songs.where((s) => (counts[s] ?? 0) == minCount).toList();
          pick = candidates[Random().nextInt(candidates.length)];
        } else {
          final idx = player.currentPath != null ? songs.indexOf(player.currentPath!) : -1;
          final prevIx = idx > 0 ? idx - 1 : 0;
          pick = songs[prevIx];
        }
        await player.stop();
        await Future.delayed(const Duration(milliseconds: 100));
        await player.play(pick);
      }
    }
    _transitioning = false;
  }

  Future<void> _nextTrack() async {
    if (_transitioning) return;
    _transitioning = true;
    final repo = context.read<PlaylistRepository>();
    final player = context.read<PlayerModel>();
    final pid = repo.selectedPlaylistId;
    if (pid != null) {
      final pl = repo.playlists.firstWhere((p) => p.id == pid);
      final songs = pl.songPaths;
      if (songs.isNotEmpty) {
        String pick;
        if (_shuffle) {
          final counts = pl.playCounts;
          final minCount = songs.map((s) => counts[s] ?? 0).reduce(min);
          final candidates = songs.where((s) => (counts[s] ?? 0) == minCount).toList();
          pick = candidates[Random().nextInt(candidates.length)];
        } else {
          final idx = player.currentPath != null ? songs.indexOf(player.currentPath!) : -1;
          final nextIx = (idx >= 0 && idx < songs.length - 1) ? idx + 1 : songs.length - 1;
          pick = songs[nextIx];
        }
        await player.stop();
        await Future.delayed(const Duration(milliseconds: 100));
        await player.play(pick);
      }
    }
    _transitioning = false;
  }

  void _rewind10() => context.read<PlayerModel>().seekRelative(-10);
  void _forward10() => context.read<PlayerModel>().seekRelative(10);
  void _toggleShuffle() => setState(() => _shuffle = !_shuffle);
  void _toggleRepeat() => setState(() => _repeat = !_repeat);

  void _toggleMute() {
    setState(() => _muted = !_muted);
    context.read<PlayerModel>().setVolume(_muted ? 0.0 : _volume);
  }

  void _onVolumeChanged(double v) {
    setState(() {
      _volume = v;
      if (v > 0) _muted = false;
    });
    context.read<PlayerModel>().setVolume(v);
  }

  String get _speakerAsset {
    if (_muted) return 'assets/icons/ph--speaker-x-fill.svg';
    if (_volume == 0) return 'assets/icons/ph--speaker-slash-fill.svg';
    if (_volume <= 0.25) return 'assets/icons/ph--speaker-none-fill.svg';
    if (_volume <= 0.5) return 'assets/icons/ph--speaker-low-fill.svg';
    return 'assets/icons/ph--speaker-high-fill.svg';
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerModel>();
    const brightGreen = Color(0xFF00FF00);
    final darkGreen = brightGreen.withAlpha((0.4 * 255).round());
    const bgColor = Color(0xFF151515);

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
                      color: brightGreen.withAlpha(128),
                      width: 32,
                      height: 32,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // Track title
          Expanded(
            child: Text(
              titleText,
              style: TextStyle(
                color: brightGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 24),

          // Current time
          Text(_formatTime(player.position), style: TextStyle(color: brightGreen)),
          const SizedBox(width: 8),

          // Seek bar
          Expanded(
            flex: 2,
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
          Text(_formatTime(player.duration), style: TextStyle(color: brightGreen)),
          const SizedBox(width: 24),

          // Playback controls
          IconButton(
            icon: SvgPicture.asset('assets/icons/ph--skip-back-fill.svg',
                color: brightGreen, width: 24, height: 24),
            onPressed: _prevTrack,
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/ph--rewind-fill.svg',
                color: brightGreen, width: 24, height: 24),
            onPressed: _rewind10,
          ),
          IconButton(
            icon: SvgPicture.asset(
              player.isPlaying
                  ? 'assets/icons/ph--pause-circle-bold.svg'
                  : 'assets/icons/ph--play-circle-bold.svg',
              color: brightGreen,
              width: 32,
              height: 32,
            ),
            onPressed: () async {
              if (player.currentPath == null) {
                final repo = context.read<PlaylistRepository>();
                final pid = repo.selectedPlaylistId;
                if (pid != null) {
                  final pl = repo.playlists.firstWhere((p) => p.id == pid);
                  final songs = pl.songPaths;
                  if (songs.isNotEmpty) {
                    String pick;
                    if (_shuffle) {
                      final counts = pl.playCounts;
                      final minCount = songs.map((s) => counts[s] ?? 0).reduce(min);
                      final candidates = songs.where((s) => (counts[s] ?? 0) == minCount).toList();
                      pick = candidates[Random().nextInt(candidates.length)];
                    } else {
                      pick = songs.first;
                    }
                    await context.read<PlayerModel>().play(pick);
                  }
                }
              } else {
                await context.read<PlayerModel>().togglePause();
              }
            },
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/ph--fast-forward-fill.svg',
                color: brightGreen, width: 24, height: 24),
            onPressed: _forward10,
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/ph--skip-forward-fill.svg',
                color: brightGreen, width: 24, height: 24),
            onPressed: _nextTrack,
          ),

          const SizedBox(width: 16),

          // Shuffle toggle
          IconButton(
            icon: SvgPicture.asset(
              _shuffle
                  ? 'assets/icons/ph--shuffle-bold.svg'
                  : 'assets/icons/ph--shuffle-off-bold.svg',
              color: _shuffle ? brightGreen : darkGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _toggleShuffle,
          ),

          // Repeat toggle
          IconButton(
            icon: SvgPicture.asset(
              _repeat
                  ? 'assets/icons/ph--repeat-bold.svg'
                  : 'assets/icons/ph--repeat-off-bold.svg',
              color: _repeat ? brightGreen : darkGreen,
              width: 24,
              height: 24,
            ),
            onPressed: _toggleRepeat,
          ),

          const SizedBox(width: 24),

          // Mute / Volume controls
          Transform.translate(
            offset: const Offset(8, 0),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 24, height: 24),
              icon: SvgPicture.asset(_speakerAsset,
                  color: brightGreen, width: 24, height: 24),
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
