import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayerSection extends StatefulWidget {
  const PlayerSection({Key? key}) : super(key: key);

  @override
  _PlayerSectionState createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection> {
  final Color brightGreen = const Color(0xFF00FF00);
  late final Color darkGreen  = brightGreen.withOpacity(0.4);
  final Color bgColor    = const Color(0xFF151515);

  double _volume = 0.75;
  bool _muted   = false;

  String get _speakerAsset {
    if (_muted) return 'assets/icons/ph--speaker-x-fill.svg';
    if (_volume == 0) return 'assets/icons/ph--speaker-slash-fill.svg';
    if (_volume <= 0.25) return 'assets/icons/ph--speaker-none-fill.svg';
    if (_volume <= 0.5) return 'assets/icons/ph--speaker-low-fill.svg';
    // ≥ 0.75
    return 'assets/icons/ph--speaker-high-fill.svg';
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
    });
  }

  void _onVolumeChanged(double val) {
    setState(() {
      _volume = val;
      if (val > 0) _muted = false;
    });
  }

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
                color: brightGreen.withOpacity(0.5),
                width: 32,
                height: 32,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Track title & artist
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Example Track – Artist Name',
                style: TextStyle(
                  color: brightGreen.withOpacity(0.8),
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

          // Playback controls
          Row(
            children: [
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
                  'assets/icons/ph--play-circle-bold.svg',
                  color: brightGreen,
                  width: 32,
                  height: 32,
                ),
                onPressed: () {},
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
            ],
          ),

          const SizedBox(width: 24),

          // Volume control (icon right next to slider)
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  _speakerAsset,
                  color: brightGreen,
                  width: 24,
                  height: 24,
                ),
                onPressed: _toggleMute,
              ),
              SizedBox(
                width: 100,
                child: Slider(
                  activeColor: brightGreen,
                  inactiveColor: darkGreen,
                  value: _muted ? 0 : _volume,
                  onChanged: _onVolumeChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
