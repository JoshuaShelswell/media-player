import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlayerSection extends StatefulWidget {
  const PlayerSection({Key? key}) : super(key: key);

  @override
  _PlayerSectionState createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection> {
  final Color brightGreen = const Color(0xFF00FF00);
  late final Color darkGreen = brightGreen.withOpacity(0.4);
  // Background color for player controls.
  final Color sectionBg = const Color(0xFF151515);

  double trackProgress = 30.0;
  double volumeLevel = 70.0;
  bool isPlaying = true;
  bool isShuffle = false;

  Widget _buildSvgIcon(String assetPath, {Color? iconColor, double width = 24, double height = 24}) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: iconColor ?? brightGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        border: Border(
          bottom: BorderSide(color: darkGreen, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Title and track info.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Media Player',
                style: TextStyle(
                  color: brightGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Currently Playing: Example Track',
                style: TextStyle(color: brightGreen, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          // Progress slider with times on each side.
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text(
                  '00:00',
                  style: TextStyle(color: brightGreen, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: trackProgress,
                    min: 0,
                    max: 100,
                    onChanged: (val) => setState(() => trackProgress = val),
                    activeColor: brightGreen,
                    inactiveColor: darkGreen,
                  ),
                ),
                Text(
                  '06:01',
                  style: TextStyle(color: brightGreen, fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Playback controls and volume.
          Row(
            children: [
              IconButton(
                icon: _buildSvgIcon('assets/icons/ph--skip-back-fill.svg'),
                onPressed: () {},
              ),
              IconButton(
                icon: _buildSvgIcon('assets/icons/ph--rewind-fill.svg'),
                onPressed: () {},
              ),
              IconButton(
                icon: isPlaying
                    ? _buildSvgIcon('assets/icons/ph--pause-circle-bold.svg')
                    : _buildSvgIcon('assets/icons/ph--play-circle-bold.svg'),
                onPressed: () => setState(() => isPlaying = !isPlaying),
              ),
              IconButton(
                icon: _buildSvgIcon('assets/icons/ph--fast-forward-fill.svg'),
                onPressed: () {},
              ),
              IconButton(
                icon: _buildSvgIcon('assets/icons/ph--skip-forward-fill.svg'),
                onPressed: () {},
              ),
              IconButton(
                icon: isShuffle
                    ? _buildSvgIcon('assets/icons/ph--shuffle-bold.svg')
                    : _buildSvgIcon('assets/icons/ph--shuffle-off-bold.svg'),
                onPressed: () => setState(() => isShuffle = !isShuffle),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: _buildSvgIcon('assets/icons/ph--speaker-high-fill.svg'),
                onPressed: () {},
              ),
              SizedBox(
                width: 100,
                child: Slider(
                  value: volumeLevel,
                  min: 0,
                  max: 100,
                  onChanged: (val) => setState(() => volumeLevel = val),
                  activeColor: brightGreen,
                  inactiveColor: darkGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
