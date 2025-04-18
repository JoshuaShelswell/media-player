import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Playlist {
  final String id;
  final String name;
  List<String> songPaths;
  Map<String, int> playCounts;

  Playlist({
    required this.id,
    required this.name,
    List<String>? songPaths,
    Map<String, int>? playCounts,
  })  : songPaths = songPaths ?? [],
        playCounts = playCounts ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songPaths': songPaths,
        'playCounts': playCounts,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      songPaths: List<String>.from(json['songPaths'] ?? []),
      playCounts: Map<String, int>.from(json['playCounts'] ?? {}),
    );
  }
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
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List data = json.decode(contents);
        _playlists
          ..clear()
          ..addAll(data.map((j) => Playlist.fromJson(j)));
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
      final data = _playlists.map((p) => p.toJson()).toList();
      await file.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint("Error saving playlists: $e");
    }
  }

  void addPlaylist(String name) {
    final newP = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(newP);
    _selectedPlaylistId = newP.id;
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

  void addSongToSelectedPlaylist(String songPath) {
    if (_selectedPlaylistId == null) return;
    final p = _playlists.firstWhere(
        (p) => p.id == _selectedPlaylistId,
        orElse: () => throw StateError('No playlist'));
    p.songPaths.add(songPath);
    p.playCounts[songPath] = 0;                // initialize count
    notifyListeners();
    savePlaylists();
  }

  /// Increment the play count for [songPath] in the selected playlist.
  void incrementPlayCount(String songPath) {
    if (_selectedPlaylistId == null) return;
    final p = _playlists.firstWhere(
        (p) => p.id == _selectedPlaylistId,
        orElse: () => throw StateError('No playlist'));
    p.playCounts[songPath] = (p.playCounts[songPath] ?? 0) + 1;
    notifyListeners();
    savePlaylists();
  }
}
