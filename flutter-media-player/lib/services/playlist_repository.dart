import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Playlist {
  final String id;
  final String name;
  List<String> songPaths;

  Playlist({
    required this.id,
    required this.name,
    List<String>? songPaths,
  }) : songPaths = songPaths ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songPaths': songPaths,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        songPaths: List<String>.from(json['songPaths'] ?? []),
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
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/playlists.json');
  }

  Future<void> loadPlaylists() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List data = json.decode(contents);
        _playlists
          ..clear()
          ..addAll(data.map((item) => Playlist.fromJson(item)));
        if (_playlists.isNotEmpty) {
          _selectedPlaylistId = _playlists.first.id;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading playlists: $e");
    }
  }

  Future<void> savePlaylists() async {
    try {
      final file = await _localFile;
      final data = _playlists.map((playlist) => playlist.toJson()).toList();
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint("Error saving playlists: $e");
    }
  }

  void addPlaylist(String name) {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(newPlaylist);
    _selectedPlaylistId = newPlaylist.id;
    notifyListeners();
    savePlaylists();
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((playlist) => playlist.id == id);
    if (_selectedPlaylistId == id) {
      _selectedPlaylistId = _playlists.isNotEmpty ? _playlists.first.id : null;
    }
    notifyListeners();
    savePlaylists();
  }

  void selectPlaylist(String id) {
    _selectedPlaylistId = id;
    notifyListeners();
  }

  void addSongToSelectedPlaylist(String songPath) {
    if (_selectedPlaylistId != null) {
      final playlist = _playlists.firstWhere(
        (p) => p.id == _selectedPlaylistId,
        orElse: () => Playlist(id: '', name: ''),
      );
      if (playlist.id.isNotEmpty) {
        playlist.songPaths.add(songPath);
        notifyListeners();
        savePlaylists();
      }
    }
  }
}
