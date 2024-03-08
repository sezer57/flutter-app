import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddClientsPage.dart';
import 'package:flutter_application_1/pages/FilterClientsPage.dart';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final String getClientsUrl = 'http://192.168.1.105:8080/api/getClients';
  List<dynamic> _clients = [];

  Future<List<dynamic>> _fetchClients() async {
    final response = await http.get(Uri.parse(getClientsUrl));
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8Body);
    } else if (response.statusCode == 204) {
      return [];
    } else {
      throw Exception('Failed to load Clients');
    }
  }

  void _filterClients() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterClientsPage()),
    );

    if (result != null && result is List<dynamic>) {
      setState(() {
        _clients = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clients'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddClientsPage()),
                  );
                  if (result == true) {
                    _fetchClients().then((clients) {
                      setState(() {
                        _clients = clients;
                      });
                    });
                  }
                },
                child: Text('Add Client'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _filterClients,
                child: Text('Filter Clients'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                var client = _clients[index];
                return ListTile(
                  title: Text(client['name'] + ' ' + client['surname']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commercial Title: ${client['commercialTitle']}'),
                      Text('Phone: ${client['phone']}'),
                      Text('Address: ${client['address']}, ${client['city']}, ${client['country']}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

