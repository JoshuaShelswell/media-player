import 'package:flutter/material.dart';

class LibrarySection extends StatelessWidget {
  const LibrarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color brightGreen = const Color(0xFF00FF00);
    final Color darkGreen = brightGreen.withOpacity(0.4);
    final Color libraryBg = const Color(0xFF1E1E1E);
    final Color searchBoxBg = const Color(0xFF151515);

    return Container(
      color: libraryBg,
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 12),
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
    );
  }
}
