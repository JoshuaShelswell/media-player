import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MediaPlayerScreen extends StatefulWidget {
  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  final List<String> playlists = ['Playlist 1', 'Playlist 2', 'Playlist 3'];
  final List<String> nowPlaying = [
    'Song 1',
    'Song 2',
    'Song 3',
    'Song 4',
    'Song 5',
  ];
  final Color neonGreen = const Color(0xFF00FF00);
  double currentSliderValue = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the default AppBar to use a custom top section:
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // -------- CUSTOM TOP BAR --------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(color: neonGreen, width: 2),
                ),
              ),
              child: Row(
                children: [
                  // Left Section: Title and Track Info
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
                  // Center Section: Slider and Time
                  Column(
                    children: [
                      SizedBox(
                        width: 250,
                        child: Slider(
                          value: currentSliderValue,
                          min: 0,
                          max: 100,
                          onChanged: (val) {
                            setState(() {
                              currentSliderValue = val;
                            });
                          },
                          activeColor: neonGreen,
                          inactiveColor: neonGreen.withOpacity(0.3),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '00:${currentSliderValue.toStringAsFixed(0)}',
                            style: TextStyle(color: neonGreen, fontSize: 12),
                          ),
                          SizedBox(width: 80),
                          Text(
                            '06:01',
                            style: TextStyle(color: neonGreen, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  // Right Section: Playback Controls with SVG icons
                  Row(
                    children: [
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--skip-back-fill.svg'),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--pause-circle-bold.svg'),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--play-circle-bold.svg'),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: _buildSvgIcon('assets/icons/ph--skip-forward-fill.svg'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // -------- MAIN CONTENT: PLAYLISTS, NOW PLAYING, LIBRARY --------
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Pane: Playlists
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border(
                        right: BorderSide(color: neonGreen, width: 2),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Playlists List Section
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
                                          style: TextStyle(color: neonGreen, fontSize: 14),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Add Playlist Button Pinned to Bottom-Left
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: InkWell(
                            onTap: () {
                              // Trigger "add playlist" functionality.
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: neonGreen, width: 2),
                                // If you want rounded corners, change borderRadius:
                                borderRadius: BorderRadius.circular(0),
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
                      color: Colors.black,
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
                                        style: TextStyle(color: neonGreen, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Remove track from nowPlaying list.
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: neonGreen,
                                        size: 20,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Pane: Library
                  Expanded(
                    child: Container(
                      color: Colors.black,
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
                              color: Colors.black,
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

  /// Helper method to load an SVG icon with an optional color override.
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
