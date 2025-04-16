import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg

class MediaPlayerScreen extends StatefulWidget {
  @override
  _MediaPlayerScreenState createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  // Sample data for demonstration
  List<String> playlists = ['Playlist 1', 'Playlist 2', 'Playlist 3'];
  List<String> nowPlaying = [
    'Song 1',
    'Song 2',
    'Song 3',
    'Song 4',
    'Song 5',
  ];

  void _playTrack() {
    // Call your Rust bridge here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Player'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Top Player Controls Section
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Currently Playing Information
                Expanded(
                  flex: 2,
                  child: Text(
                    'Currently Playing: SP002 Radio Show',
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Progress Bar Section
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Slider(
                        value: 30,
                        min: 0,
                        max: 100,
                        onChanged: (val) {},
                        activeColor: Color(0xFF00FF00),
                        inactiveColor: Color(0xFF006600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('00:30', style: TextStyle(color: Color(0xFF00FF00))),
                          Text('06:01', style: TextStyle(color: Color(0xFF00FF00))),
                        ],
                      )
                    ],
                  ),
                ),
                // Playback Control Buttons Using SVGs
                Row(
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/prev.svg',
                        color: Color(0xFF00FF00),
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/play.svg',
                        color: Color(0xFF00FF00),
                        width: 24,
                        height: 24,
                      ),
                      onPressed: _playTrack,
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/next.svg',
                        color: Color(0xFF00FF00),
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main Content: Playlists, Now Playing, and Library Sections
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Playlists Pane
                Container(
                  width: 200,
                  color: Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        'Playlists',
                        style: TextStyle(
                          color: Color(0xFF00FF00),
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
                                style: TextStyle(color: Color(0xFF00FF00)),
                              ),
                            );
                          },
                        ),
                      ),
                      // Updated Add Playlist Button with new style parameters.
                      ElevatedButton.icon(
                        icon: SvgPicture.asset(
                          'assets/icons/add_playlist.svg',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                        label: Text('Add Playlist'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00FF00), // replaced "primary"
                          foregroundColor: Colors.black, // replaced "onPrimary"
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
                // Now Playing Pane
                Container(
                  width: 300,
                  color: Colors.black,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        'Now Playing',
                        style: TextStyle(
                          color: Color(0xFF00FF00),
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
                                      style: TextStyle(color: Color(0xFF00FF00)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Color(0xFF00FF00)),
                                    onPressed: () {
                                      // Remove track from the list.
                                    },
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
                // Library Pane
                Expanded(
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          'Library',
                          style: TextStyle(
                            color: Color(0xFF00FF00),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          style: TextStyle(color: Color(0xFF00FF00)),
                          decoration: InputDecoration(
                            hintText: 'Search library...',
                            hintStyle: TextStyle(color: Color(0xFF008800)),
                            filled: true,
                            fillColor: Color(0xFF002200),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF00FF00)),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Center(
                            child: Text(
                              'No music found in library.\n Add Music Folder',
                              style: TextStyle(color: Color(0xFF00FF00)),
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
    );
  }
}
