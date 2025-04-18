// lib/services/playlist_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Playlist {
  final String id;
  String name;                     // ← made mutable
  List<String> songPaths;
  Map<String,int> playCounts;
  
  Playlist({
    required this.id,
    required this.name,
    List<String>? songPaths,
    Map<String,int>? playCounts,
  })  : songPaths = songPaths ?? [],
        playCounts = playCounts ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songPaths': songPaths,
        'playCounts': playCounts,
      };

  factory Playlist.fromJson(Map json) => Playlist(
        id: json['id'],
        name: json['name'],
        songPaths: List<String>.from(json['songPaths'] ?? []),
        playCounts:
            Map<String, int>.from(json['playCounts'] ?? <String, int>{}),
      );
}

class PlaylistRepository extends ChangeNotifier {
  static final PlaylistRepository _instance = PlaylistRepository._internal();
  factory PlaylistRepository() => _instance;
  PlaylistRepository._internal() {
    loadPlaylists();
  }

  final List<Playlist> _playlists = [];
  String? _selectedPlaylistId;

  List<Playlist> get playlists => List.unmodifiable(_playlists);
  String? get selectedPlaylistId => _selectedPlaylistId;

  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/playlists.json');
  }

  Future<void> loadPlaylists() async {
    try {
      final f = await _localFile;
      if (await f.exists()) {
        final data = json.decode(await f.readAsString()) as List;
        _playlists
          ..clear()
          ..addAll(data.map((e) => Playlist.fromJson(e)));
        if (_playlists.isNotEmpty) {
          _selectedPlaylistId = _playlists.first.id;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }
  }

  Future<void> savePlaylists() async {
    try {
      final f = await _localFile;
      final data = _playlists.map((p) => p.toJson()).toList();
      await f.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  void addPlaylist(String name) {
    final p = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(p);
    _selectedPlaylistId = p.id;
    notifyListeners();
    savePlaylists();
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    if (_selectedPlaylistId == id) {
      _selectedPlaylistId =
          _playlists.isNotEmpty ? _playlists.first.id : null;
    }
    notifyListeners();
    savePlaylists();
  }

  void selectPlaylist(String id) {
    _selectedPlaylistId = id;
    notifyListeners();
  }

  /// ← New:
  void renamePlaylist(String id, String newName) {
    final p = _playlists.firstWhere((p) => p.id == id);
    p.name = newName;
    notifyListeners();
    savePlaylists();
  }

  void incrementPlayCount(String path) {
    if (_selectedPlaylistId == null) return;
    final pl =
        _playlists.firstWhere((p) => p.id == _selectedPlaylistId!);
    pl.playCounts[path] = (pl.playCounts[path] ?? 0) + 1;
    savePlaylists();
    notifyListeners();
  }

  void addSongToSelectedPlaylist(String path) {
    if (_selectedPlaylistId == null) return;
    final pl =
        _playlists.firstWhere((p) => p.id == _selectedPlaylistId!);
    pl.songPaths.add(path);
    pl.playCounts[path] = pl.playCounts[path] ?? 0;
    notifyListeners();
    savePlaylists();
  }
}
