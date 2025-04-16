// flutter_remote/lib/remote_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RemotePage extends StatefulWidget {
  @override
  _RemotePageState createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  final TextEditingController _ipController = TextEditingController();
  WebSocketChannel? _channel;
  bool _connected = false;
  String _trackTitle = "";
  double _duration = 0.0;
  double _position = 0.0;
  int _state = 0; // 0=stopped, 1=playing, 2=paused

  String _formatTime(double seconds) {
    int totalSec = seconds.floor();
    int minutes = totalSec ~/ 60;
    int sec = totalSec % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  void _connect() async {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    String url = 'ws://$ip:3000';
    try {
      _channel = await WebSocket.connect(url);
      setState(() {
        _connected = true;
      });
      _channel!.listen((data) {
        try {
          final status = jsonDecode(data);
          if (status is Map) {
            setState(() {
              _trackTitle = status['track'] ?? "";
              _duration = (status['duration'] ?? 0.0) * 1.0;
              _position = (status['position'] ?? 0.0) * 1.0;
              _state = status['state'] ?? 0;
            });
          }
        } catch (_) {}
      }, onDone: () {
        setState(() {
          _connected = false;
          _channel = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Disconnected from server')));
      }, onError: (error) {
        setState(() {
          _connected = false;
          _channel = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connection error: $error')));
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    setState(() {
      _connected = false;
    });
  }

  void _sendCommand(String cmd) {
    _channel?.sink.add(jsonEncode({"cmd": cmd}));
  }

  void _togglePlayPause() {
    if (_state == 1) {
      _sendCommand("pause");
      setState(() {
        _state = 2;
      });
    } else if (_state == 2) {
      _sendCommand("play");
      setState(() {
        _state = 1;
      });
    }
  }

  void _stop() {
    _sendCommand("stop");
    setState(() {
      _state = 0;
      _trackTitle = "";
      _position = 0.0;
      _duration = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_connected) {
      return Scaffold(
        appBar: AppBar(title: Text('Connect to Media Player')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter the IP address of the player:', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Server IP',
                      hintText: 'e.g. 192.168.1.100'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _connect,
                  child: Text('CONNECT'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Media Player Remote'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _disconnect,
              tooltip: 'Disconnect',
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _trackTitle.isEmpty ? 'No track loaded' : _trackTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              if (_trackTitle.isNotEmpty) ...[
                Slider(
                  value: (_duration > 0) ? _position.clamp(0.0, _duration) : 0.0,
                  max: (_duration > 0) ? _duration : 1.0,
                  onChanged: null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(_position)),
                    Text(_formatTime(_duration)),
                  ],
                ),
              ] else
                SizedBox(height: 48),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_state == 1 ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    iconSize: 64,
                    onPressed: (_state == 0) ? null : _togglePlayPause,
                    tooltip: _state == 1 ? 'Pause' : 'Play',
                  ),
                  SizedBox(width: 30),
                  IconButton(
                    icon: Icon(Icons.stop),
                    iconSize: 48,
                    onPressed: (_state != 0) ? _stop : null,
                    tooltip: 'Stop',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
