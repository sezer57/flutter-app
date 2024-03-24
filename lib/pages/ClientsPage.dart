import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddClientsPage.dart';
import 'package:flutter_application_1/pages/FilterClientsPage.dart';
import 'package:flutter_application_1/pages/ClientPdfPage.dart'; // ClientPdfPage eklendi

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final String getClientsUrl = 'http://192.168.1.105:8080/api/getClients';
  List<dynamic> clients = [];

  Future<void> _fetchClients() async {
    final response = await http.get(Uri.parse(getClientsUrl));
    if (response.statusCode == 200) {
      setState(() {
        clients = json.decode(response.body);
      });
    } else {
      print("product empty");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  void _filterClients() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterClientsPage()),
    );

    if (result != null && result is List<dynamic>) {
      setState(() {
        clients = result;
      });
    }
  }

  void _navigateToPdfPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfPage()),
    );
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
                        clients = clients;
                      });
                    });
                  }
                },
                child: Text('Add Client'),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: _filterClients,
                child: Text('Filter Clients'),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: _navigateToPdfPage,
                child: Text('All Clients'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                var client = clients[index];
                return ListTile(
                  title: Text(client['name'] + ' ' + client['surname']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commercial Title: ${client['commercialTitle']}'),
                      Text('Phone: ${client['phone']}'),
                      Text(
                          'Address: ${client['address']}, ${client['city']}, ${client['country']}'),
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
