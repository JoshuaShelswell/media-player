import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LibrarySection extends StatefulWidget {
  const LibrarySection({super.key});

  @override
  State<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends State<LibrarySection> {
  final TextEditingController _searchController = TextEditingController();

  // these can’t both be const if one uses withAlpha((0.4 * 255).round());
  static const Color brightGreen = Color(0xFF00FF00);
  late final Color darkGreen = brightGreen.withAlpha((0.4 * 255).round());
  static const Color sectionBg = Color(0xFF1F1F1F);

  bool _gridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: sectionBg, // no top/bottom borders
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // HEADER
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ph--book-open-text-fill.svg',
                width: 20,
                height: 20,
                color: brightGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                'Library',
                style: TextStyle(
                  color: brightGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--grid-nine-fill.svg',
                  width: 20,
                  height: 20,
                  color: brightGreen,
                ),
                onPressed: () => setState(() => _gridView = true),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--list-bullets-fill.svg',
                  width: 20,
                  height: 20,
                  color: brightGreen,
                ),
                onPressed: () => setState(() => _gridView = false),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // SEARCH BAR with fillColor = 0xFF151515
          TextField(
            controller: _searchController,
            style: const TextStyle(color: brightGreen),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF151515),
              hintText: 'Search Library...',
              hintStyle: TextStyle(
                color: brightGreen.withAlpha((0.4 * 255).round()),
              ),
              prefixIcon: const Icon(Icons.search, color: brightGreen),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: darkGreen),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: brightGreen),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // placeholder for your grid/list
          Expanded(child: Container()),

          // ADD FOLDER BUTTON in center
          // Add folder-pick + recursive scan later
          Center(
            child: InkWell(
              onTap: () {
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--folder-plus-fill.svg',
                      width: 24,
                      height: 24,
                      color: brightGreen,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Folder',
                      style: TextStyle(
                        color: brightGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
