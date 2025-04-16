import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaPlayerScreen extends StatefulWidget {
  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  // Bright neon green for text and icons.
  final Color brightGreen = const Color(0xFF00FF00);
  
  // Dark green (a semi-transparent version) for borders.
  late final Color darkGreen = brightGreen.withOpacity(0.4);
  
  // Off-black background for outer areas.
  final Color offBlack = const Color(0xFF202020);
  
  // For the Library section's background.
  final Color libraryGray = const Color(0xFF1E1E1E);
  
  // Use this same color for the inside of the search box, and now for all player sections.
  final Color searchBoxBg = const Color(0xFF151515);

  // Example data.
  final List<String> playlists = ['Playlist 1', 'Playlist 2', 'Playlist 3'];
  final List<String> nowPlaying = [
    'Song 1',
    'Song 2',
    'Song 3',
    'Song 4',
    'Song 5',
  ];

  double trackProgress = 30.0; // Track progress (0-100)
  double volumeLevel = 70.0;   // Volume (0-100)
  bool isShuffle = false;      // Toggle for shuffle
  bool isPlaying = true;       // Toggle for play/pause

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,  // So our custom container is visible.
      body: Container(
        // Outer container with border and overall background.
        decoration: BoxDecoration(
          color: offBlack,
          border: Border.all(color: darkGreen, width: 2),
        ),
        child: Column(
          children: [
            // ---------- TOP CONTROL BAR (Player Section) ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // Changed background from offBlack to searchBoxBg for the player section.
              decoration: BoxDecoration(
                color: searchBoxBg,
                border: Border(
                  bottom: BorderSide(color: darkGreen, width: 2),
                ),
              ),
              child: Row(
                children: [
                  // Left: Title and track info.
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
                  Spacer(),
                  // Middle: Progress slider with start and end times on sides.
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
                            onChanged: (val) {
                              setState(() {
                                trackProgress = val;
                              });
                            },
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
                  Spacer(),
                  // Right: Playback controls and volume.
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
                      // Play/Pause toggle.
                      IconButton(
                        icon: isPlaying
                            ? _buildSvgIcon('assets/icons/ph--pause-circle-bold.svg')
                            : _buildSvgIcon('assets/icons/ph--play-circle-bold.svg'),
                        onPressed: () {
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                      ),
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--fast-forward-fill.svg'),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--skip-forward-fill.svg'),
                        onPressed: () {},
                      ),
                      // Shuffle toggle.
                      IconButton(
                        icon: isShuffle
                            ? _buildSvgIcon('assets/icons/ph--shuffle-bold.svg')
                            : _buildSvgIcon('assets/icons/ph--shuffle-off-bold.svg'),
                        onPressed: () {
                          setState(() {
                            isShuffle = !isShuffle;
                          });
                        },
                      ),
                      SizedBox(width: 16),
                      // Volume icon and slider.
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
                          onChanged: (val) {
                            setState(() {
                              volumeLevel = val;
                            });
                          },
                          activeColor: brightGreen,
                          inactiveColor: darkGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ---------- MAIN CONTENT ----------
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Pane: Playlists (background: searchBoxBg)
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: searchBoxBg,
                      border: Border(
                        right: BorderSide(color: darkGreen, width: 2),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Playlists list.
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Playlists',
                                  style: TextStyle(
                                    color: brightGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: playlists.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(
                                        playlists[index],
                                        style: TextStyle(
                                          color: brightGreen,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // "Add Playlist" button pinned to bottom left.
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: InkWell(
                            onTap: () {
                              // Add Playlist logic.
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: searchBoxBg,
                                border: Border.all(color: darkGreen, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildSvgIcon(
                                    'assets/icons/ph--folder-plus-fill.svg',
                                    iconColor: brightGreen,
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add Playlist',
                                    style: TextStyle(
                                      color: brightGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Middle Pane: Now Playing (background: searchBoxBg)
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: searchBoxBg,
                      border: Border(
                        right: BorderSide(color: darkGreen, width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            color: brightGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: nowPlaying.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      nowPlaying[index],
                                      style: TextStyle(
                                        color: brightGreen,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Remove track action.
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: brightGreen,
                                      size: 20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right Pane: Library (remains unchanged)
                  Expanded(
                    child: Container(
                      color: libraryGray,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Library',
                            style: TextStyle(
                              color: brightGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Search box: background as searchBoxBg.
                          Container(
                            decoration: BoxDecoration(
                              color: searchBoxBg,
                              border: Border.all(color: darkGreen, width: 1),
                            ),
                            child: TextField(
                              style: TextStyle(color: brightGreen, fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                hintText: 'Search library...',
                                hintStyle: TextStyle(color: brightGreen),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: Text(
                                'No music found in library.\nAdd Music Folder',
                                style: TextStyle(color: brightGreen, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to load an SVG icon with optional color and size overrides.
  Widget _buildSvgIcon(String assetPath,
      {Color? iconColor, double width = 24, double height = 24}) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: iconColor ?? brightGreen,
    );
  }
}
