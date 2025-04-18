// lib/screens/library_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:provider/provider.dart';

class LibrarySection extends StatefulWidget {
  const LibrarySection({super.key});

  @override
  State<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends State<LibrarySection> {
  final TextEditingController _searchController = TextEditingController();
  bool _gridView = true;

  static const Color brightGreen = Color(0xFF00FF00);
  late final Color darkGreen =
      brightGreen.withAlpha((0.4 * 255).round());
  static const Color sectionBg = Color(0xFF1F1F1F);

  // constants for grid
  static const double _itemSize = 80;
  static const double _spacing  = 20;
  static const int    _columns  = 4;
  static const int    _rows     = 4;  // now 4 rows for a 4×4 square

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // calculate total width of the wrap container
    final wrapWidth = _columns * _itemSize + (_columns - 1) * _spacing;
    // total item count for a square grid
    final totalItems = _columns * _rows;

    return Container(
      color: sectionBg,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Top header row
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--arrow-left-bold.svg',
                  width: 20,
                  height: 20,
                  color: brightGreen,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--arrow-right-bold.svg',
                  width: 20,
                  height: 20,
                  color: brightGreen,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--arrow-up-bold.svg',
                  width: 20,
                  height: 20,
                  color: brightGreen,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: brightGreen),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    filled: true,
                    fillColor: const Color(0xFF151515),
                    hintText: 'Search Library…',
                    hintStyle: TextStyle(
                      color: brightGreen.withAlpha((0.4 * 255).round()),
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: brightGreen, size: 20),
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
              ),
              const SizedBox(width: 12),
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

          const SizedBox(height: 12),

          // Main content: fixed-width, centered grid or list
          Expanded(
            child: _gridView
                ? SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: wrapWidth,
                        child: Padding(
                          // move grid down by half an item (40px)
                          padding: const EdgeInsets.only(top: _itemSize / 2),
                          child: Wrap(
                            spacing: _spacing,
                            runSpacing: _spacing,
                            children: List.generate(totalItems, (_) {
                              return Container(
                                width: _itemSize,
                                height: _itemSize,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF151515),
                                  border:
                                      Border.all(color: darkGreen, width: 1.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/ph--music-notes-fill.svg',
                                    width: 24,
                                    height: 24,
                                    color: brightGreen.withAlpha(128),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'List view coming soon…',
                          style:
                              TextStyle(color: brightGreen, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 12),

          // Add Folder button
          Center(
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                          fontWeight: FontWeight.w500),
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
