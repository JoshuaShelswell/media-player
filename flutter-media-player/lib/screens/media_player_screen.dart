import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaPlayerScreen extends StatefulWidget {
  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  // Define the neon green we use for all borders and text.
  final Color neonGreen = const Color(0xFF00FF00);
  
  // Off-black background for most areas
  final Color offBlack = const Color(0xFF202020);
  
  // A slightly lighter gray for the library pane background.
  final Color libraryGray = const Color(0xFF2A2A2A);
  
  // Example data:
  final List<String> playlists = ['Playlist 1', 'Playlist 2', 'Playlist 3'];
  final List<String> nowPlaying = [
    'Song 1',
    'Song 2',
    'Song 3',
    'Song 4',
    'Song 5',
  ];

  double trackProgress = 30.0; // current track progress (0-100)
  double volumeLevel = 70.0;    // volume (0-100)
  bool isShuffle = false;       // shuffle state
  bool isPlaying = true;        // playing vs paused

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // so our custom container is seen
      body: Container(
        // Outer border around the entire app
        decoration: BoxDecoration(
          color: offBlack,
          border: Border.all(color: neonGreen, width: 2),
        ),
        child: Column(
          children: [
            // ---------- TOP CONTROL BAR ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: offBlack,
                border: Border(
                  bottom: BorderSide(color: neonGreen, width: 2),
                ),
              ),
              child: Row(
                children: [
                  // Left: Title and current track info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media Player',
                        style: TextStyle(
                          color: neonGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Currently Playing: Example Track',
                        style: TextStyle(color: neonGreen, fontSize: 14),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Middle: Progress bar with start and end time on either side
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          '00:00',
                          style: TextStyle(color: neonGreen, fontSize: 12),
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
                            activeColor: neonGreen,
                            inactiveColor: neonGreen.withOpacity(0.3),
                          ),
                        ),
                        Text(
                          '06:01',
                          style: TextStyle(color: neonGreen, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  // Right: Playback controls and volume
                  Row(
                    children: [
                      // Skip Back
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--skip-back-fill.svg'),
                        onPressed: () {},
                      ),
                      // Rewind
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--rewind-fill.svg'),
                        onPressed: () {},
                      ),
                      // Play/Pause toggle
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
                      // Fast Forward
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--fast-forward-fill.svg'),
                        onPressed: () {},
                      ),
                      // Skip Forward
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--skip-forward-fill.svg'),
                        onPressed: () {},
                      ),
                      // Shuffle toggle
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
                      // Volume Icon and Volume Slider
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
                          activeColor: neonGreen,
                          inactiveColor: neonGreen.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ---------- MAIN CONTENT (Three Panels) ----------
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Pane: Playlists
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: offBlack,
                      border: Border(
                        right: BorderSide(color: neonGreen, width: 2),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Playlists list
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Playlists',
                                  style: TextStyle(
                                    color: neonGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: playlists.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          playlists[index],
                                          style: TextStyle(
                                            color: neonGreen,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // "Add Playlist" button at bottom left
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: InkWell(
                            onTap: () {
                              // Add Playlist logic here.
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: offBlack,
                                border: Border.all(color: neonGreen, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildSvgIcon(
                                    'assets/icons/ph--folder-plus-fill.svg',
                                    iconColor: neonGreen,
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add Playlist',
                                    style: TextStyle(
                                      color: neonGreen,
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
                  // Middle Pane: Now Playing
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: offBlack,
                      border: Border(
                        right: BorderSide(color: neonGreen, width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            color: neonGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: nowPlaying.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        nowPlaying[index],
                                        style: TextStyle(
                                          color: neonGreen,
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
                                        color: neonGreen,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right Pane: Library (with a gray background)
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
                              color: neonGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: libraryGray,
                              border: Border.all(color: neonGreen, width: 1),
                            ),
                            child: TextField(
                              style: TextStyle(color: neonGreen, fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                hintText: 'Search library...',
                                hintStyle: TextStyle(color: neonGreen.withOpacity(0.4)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: Text(
                                'No music found in library.\nAdd Music Folder',
                                style: TextStyle(color: neonGreen, fontSize: 14),
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

  /// Helper to load an SVG icon from assets.
  Widget _buildSvgIcon(String assetPath,
      {Color? iconColor, double width = 24, double height = 24}) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: iconColor ?? neonGreen,
    );
  }
}
