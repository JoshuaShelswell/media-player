// lib/screens/playing_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayerSection extends StatefulWidget {
  const PlayerSection({super.key});

  @override
  State<PlayerSection> createState() => PlayerSectionState();
}

class PlayerSectionState extends State<PlayerSection> {
  final Color brightGreen = const Color(0xFF00FF00);
  late final Color darkGreen = brightGreen.withAlpha((0.4 * 255).round());
  final Color bgColor = const Color(0xFF151515);

  double _volume = 0.75;
  bool _muted = false;
  bool _shuffle = false;
  bool _playing = false;

  String get _speakerAsset {
    if (_muted) return 'assets/icons/ph--speaker-x-fill.svg';
    if (_volume == 0) return 'assets/icons/ph--speaker-slash-fill.svg';
    if (_volume <= 0.25) return 'assets/icons/ph--speaker-none-fill.svg';
    if (_volume <= 0.5) return 'assets/icons/ph--speaker-low-fill.svg';
    return 'assets/icons/ph--speaker-high-fill.svg';
  }

  void _toggleMute() => setState(() => _muted = !_muted);

  void _onVolumeChanged(double val) {
    setState(() {
      _volume = val;
      if (val > 0) _muted = false;
    });
  }

  void _toggleShuffle() => setState(() => _shuffle = !_shuffle);
  void _togglePlay() => setState(() => _playing = !_playing);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: darkGreen, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Album art placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              border: Border.all(color: darkGreen, width: 2),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/ph--music-notes-fill.svg',
                color: brightGreen.withAlpha((0.5 * 255).round()),
                width: 32,
                height: 32,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Track info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Media Player',
                style: TextStyle(
                  color: brightGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Example Track – Artist Name',
                style: TextStyle(
                  color: brightGreen.withAlpha((0.8 * 255).round()),
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Progress bar inline
          Text('0:00', style: TextStyle(color: brightGreen)),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              activeColor: brightGreen,
              inactiveColor: darkGreen,
              value: 0.2,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 8),
          Text('3:45', style: TextStyle(color: brightGreen)),

          const SizedBox(width: 24),

          // Playback controls + shuffle
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--skip-back-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--rewind-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset(
              _playing
                  ? 'assets/icons/ph--pause-circle-bold.svg'
                  : 'assets/icons/ph--play-circle-bold.svg',
              color: brightGreen,
              width: 32,
              height: 32,
            ),
            onPressed: _togglePlay,
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--fast-forward-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ph--skip-forward-fill.svg',
              color: brightGreen,
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
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

          // Push volume controls to the right
          const SizedBox(width: 24),

          // Volume icon nudged 8px right to hug the slider
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

          // Volume slider
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