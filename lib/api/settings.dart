import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _ipController = TextEditingController();
  String? _savedIP;

  @override
  void initState() {
    super.initState();
    _loadIP();
  }

  _loadIP() async {
    _savedIP = await loadIP();
    setState(() {
      _ipController.text = _savedIP!;
    });
  }
  _saveIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', _ipController.text);
    setState(() {
      _savedIP = _ipController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Enter IP address',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIP,
              child: Text('Save IP'),
            ),
            if (_savedIP != null) ...[
              SizedBox(height: 20),
              Text('Saved IP: $_savedIP'),
            ],
          ],
        ),
      ),
    );
  }
}
