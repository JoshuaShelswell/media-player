// flutter_remote/lib/screens/connection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_remote/screens/controller_screen.dart';
import 'package:flutter_remote/services/player_api.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _addressController = TextEditingController();
  final PlayerApiService _apiService = PlayerApiService();
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _addressController.text = '192.168.1.100:8080';
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final parts = _addressController.text.split(':');
      final address = parts[0];
      final port = int.parse(parts.length > 1 ? parts[1] : '8080');

      final connected = await _apiService.connect(address, port);

      if (connected) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ControllerScreen(apiService: _apiService),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to the server';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Media Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the IP address and port of your media player:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Server Address',
                hintText: 'e.g., 192.168.1.100:8080',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _isConnecting ? null : _connect,
              child: _isConnecting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Connect'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}