// flutter_remote/lib/services/player_api.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_remote/models/track.dart';
import 'package:flutter_remote/models/playlist.dart';

class PlayerApiService {
  WebSocketChannel? _channel;
  String? _serverAddress;
  final StreamController<PlayerEvent> _eventController = StreamController.broadcast();
  
  Stream<PlayerEvent> get events => _eventController.stream;
  
  bool get isConnected => _channel != null;
  
  Future<bool> connect(String address, int port) async {
    try {
      _serverAddress = 'ws://$address:$port';
      _channel = WebSocketChannel.connect(Uri.parse(_serverAddress!));
      
      // Listen for events from the server
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        final event = _parseEvent(data);
        if (event != null) {
          _eventController.add(event);
        }
      }, onDone: () {
        _channel = null;
        _eventController.add(PlayerEvent.connectionClosed());
      }, onError: (error) {
        _channel = null;
        _eventController.add(PlayerEvent.error(error.toString()));
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
  
  void play(String path) {
    _sendCommand({
      'type': 'Play',
      'path': path,
    });
  }
  
  void pause() {
    _sendCommand({'type': 'Pause'});
  }
  
  void resume() {
    _sendCommand({'type': 'Resume'});
  }
  
  void next() {
    _sendCommand({'type': 'Next'});
  }
  
  void previous() {
    _sendCommand({'type': 'Previous'});
  }
  
  void setVolume(double volume) {
    _sendCommand({
      'type': 'SetVolume',
      'value': volume,
    });
  }
  
  void seek(double position) {
    _sendCommand({
      'type': 'Seek',
      'position': position,
    });
  }
  
  void loadPlaylist(int id) {
    _sendCommand({
      'type': 'LoadPlaylist',
      'id': id,
    });
  }
  
  void _sendCommand(Map<String, dynamic> command) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(command));
    }
  }
  
  PlayerEvent? _parseEvent(dynamic data) {
    final type = data['type'];
    switch (type) {
      case 'TrackChanged':
        return PlayerEvent.trackChanged(
          title: data['title'],
          artist: data['artist'],
          duration: data['duration'],
          position: data['position'],
        );
      case 'PlaybackStateChanged':
        return PlayerEvent.playbackStateChanged(
          isPlaying: data['is_playing'],
        );
      case 'VolumeChanged':
        return PlayerEvent.volumeChanged(
          volume: data['value'],
        );
      case 'PlaylistsUpdated':
        // Parse playlists
        return null;
      default:
        return null;
    }
  }
}

class PlayerEvent {
  final PlayerEventType type;
  final Map<String, dynamic> data;
  
  PlayerEvent(this.type, this.data);
  
  factory PlayerEvent.trackChanged({
    required String title,
    required String artist,
    required double duration,
    required double position,
  }) {
    return PlayerEvent(PlayerEventType.trackChanged, {
      'title': title,
      'artist': artist,
      'duration': duration,
      'position': position,
    });
  }
  
  factory PlayerEvent.playbackStateChanged({required bool isPlaying}) {
    return PlayerEvent(PlayerEventType.playbackStateChanged, {
      'isPlaying': isPlaying,
    });
  }
  
  factory PlayerEvent.volumeChanged({required double volume}) {
    return PlayerEvent(PlayerEventType.volumeChanged, {
      'volume': volume,
    });
  }
  
  factory PlayerEvent.connectionClosed() {
    return PlayerEvent(PlayerEventType.connectionClosed, {});
  }
  
  factory PlayerEvent.error(String message) {
    return PlayerEvent(PlayerEventType.error, {'message': message});
  }
}

enum PlayerEventType {
  trackChanged,
  playbackStateChanged,
  volumeChanged,
  connectionClosed,
  error,
}