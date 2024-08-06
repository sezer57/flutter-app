import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_application_1/components/theme.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _ipController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  List<Map<String, String>> _savedIPs = [];
  String? _selectedIP;

  @override
  void initState() {
    super.initState();
    _loadIPs();
  }

  _loadIPs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedIPs = prefs.getString('ips');
    List<dynamic> ipList = savedIPs != null ? json.decode(savedIPs) : [];
    String? selectedIP = prefs.getString('ip');

    if (ipList.isNotEmpty) {
      setState(() {
        _savedIPs = List<Map<String, String>>.from(
            ipList.map((ip) => Map<String, String>.from(ip)));
        _selectedIP = selectedIP;
      });
    } else {
      setState(() {
        _savedIPs = []; // Başlangıç değeri olarak boş bir liste atanıyor
        _savedIPs.add({
          'ip': '104.248.42.73',
          'name': 'Test',
        });
        _selectedIP = "104.248.42.73";
      });
      await prefs.setString('ips', json.encode(_savedIPs));
    }
  }

  _saveIP() async {
    if (_ipController.text.isNotEmpty && _nameController.text.isNotEmpty) {
      setState(() {
        _savedIPs.add({
          'ip': _ipController.text,
          'name': _nameController.text,
        });
        _ipController.clear();
        _nameController.clear();
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('ips', json.encode(_savedIPs));
    }
  }

  _deleteIP(int index) async {
    setState(() {
      _savedIPs.removeAt(index);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ips', json.encode(_savedIPs));
  }

  _editIP(int index) {
    _ipController.text = _savedIPs[index]['ip']!;
    _nameController.text = _savedIPs[index]['name']!;
    _deleteIP(index);
  }

  _selectIP(int index) async {
    setState(() {
      _selectedIP = _savedIPs[index]['ip'];
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', _selectedIP!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Settings',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter Name',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Enter IP address',
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveIP,
              child: Text('Save IP'),
            ),
            SizedBox(height: 12),
            if (_selectedIP != null) ...[
              SizedBox(height: 12),
              Text('Selected IP: $_selectedIP'),
            ],
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _savedIPs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: _savedIPs[index]['ip'] == _selectedIP
                        ? Colors.green[100]
                        : null,
                    title: Text(_savedIPs[index]['name']!),
                    subtitle: Text(_savedIPs[index]['ip']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editIP(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteIP(index),
                        ),
                      ],
                    ),
                    onTap: () => _selectIP(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
