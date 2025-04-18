// lib/screens/library_section.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class LibrarySection extends StatefulWidget {
  const LibrarySection({super.key});

  @override
  State<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends State<LibrarySection> {
  final TextEditingController _searchController = TextEditingController();
  bool _gridView = true;

  // current folder and its files
  String? _currentFolder;
  List<_LibraryFile> _files = [];

  static const Color brightGreen = Color(0xFF00FF00);
  late final Color darkGreen =
      brightGreen.withAlpha((0.4 * 255).round());
  static const Color sectionBg = Color(0xFF1F1F1F);

  // grid configuration
  static const double _itemSize = 80;
  static const double _spacing  = 20;
  static const int    _columns  = 4;
  static const int    _rows     = 4;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    final folder = await FilePicker.platform.getDirectoryPath();
    if (folder == null) return;

    final dir = Directory(folder);
    // find a thumbnail image in the folder root
    String? thumb;
    for (var ent in dir.listSync()) {
      if (ent is File) {
        final lower = ent.path.toLowerCase();
        if (lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png')) {
          thumb = ent.path;
          break;
        }
      }
    }

    // gather audio files
    final exts = {
      '.mp3', '.aac', '.flac', '.wav',
      '.ogg', '.m4a', '.wma', '.alac', '.opus'
    };
    final files = <_LibraryFile>[];
    for (var ent in dir.listSync()) {
      if (ent is File) {
        final ext = ent.path.toLowerCase().substring(ent.path.lastIndexOf('.'));
        if (exts.contains(ext)) {
          final title = ent.uri.pathSegments.last;
          files.add(_LibraryFile(ent.path, title, thumb));
        }
      }
    }

    setState(() {
      _currentFolder = folder;
      _files = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    // compute wrap width
    final wrapWidth = _columns * _itemSize + (_columns - 1) * _spacing;
    // total slots to show
    final totalItems = _columns * _rows;

    return Container(
      color: sectionBg,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Top header row (arrows, search, toggle)
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--arrow-left-bold.svg',
                  width: 20, height: 20, color: brightGreen,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--arrow-right-bold.svg',
                  width: 20, height: 20, color: brightGreen,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--arrow-up-bold.svg',
                  width: 20, height: 20, color: brightGreen,
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
                  width: 20, height: 20, color: brightGreen,
                ),
                onPressed: () => setState(() => _gridView = true),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/ph--list-bullets-fill.svg',
                  width: 20, height: 20, color: brightGreen,
                ),
                onPressed: () => setState(() => _gridView = false),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main content: grid or list
          Expanded(
            child: _gridView
                ? SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: wrapWidth,
                        child: Padding(
                          // move grid down by half an item
                          padding: const EdgeInsets.only(top: _itemSize / 2),
                          child: Wrap(
                            spacing: _spacing,
                            runSpacing: _spacing,
                            children: List.generate(totalItems, (i) {
                              // if no folder selected: show placeholder icon only
                              if (_currentFolder == null) {
                                return Container(
                                  width: _itemSize,
                                  height: _itemSize,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF151515),
                                    border: Border.all(
                                        color: darkGreen, width: 1.5),
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
                              }

                              // folder selected: show actual files
                              if (i < _files.length) {
                                final f = _files[i];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: _itemSize,
                                      height: _itemSize,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF151515),
                                        border: Border.all(
                                            color: darkGreen, width: 1.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: f.thumbnail != null
                                          ? Image.file(
                                              File(f.thumbnail!),
                                              fit: BoxFit.cover,
                                              width: _itemSize,
                                              height: _itemSize,
                                            )
                                          : Center(
                                              child: SvgPicture.asset(
                                                'assets/icons/ph--music-notes-fill.svg',
                                                width: 24,
                                                height: 24,
                                                color: brightGreen
                                                    .withAlpha(128),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: _itemSize,
                                      child: Text(
                                        f.title,
                                        style: TextStyle(
                                            color: brightGreen,
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // empty slot beyond file count
                              return SizedBox(
                                width: _itemSize,
                                height: _itemSize + 20,
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
              onTap: _pickFolder,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ph--folder-plus-fill.svg',
                      width: 24, height: 24, color: brightGreen,
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

/// model for library items
class _LibraryFile {
  final String filePath;
  final String title;
  final String? thumbnail;
  _LibraryFile(this.filePath, this.title, this.thumbnail);
}
