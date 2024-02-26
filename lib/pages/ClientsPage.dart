import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddClientsPage.dart';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final String getClientsUrl =
      'http://192.168.56.1:8080/api/getClients'; // Corrected URL

  Future<List<dynamic>> _fetchClients() async {
    final response = await http
        .get(Uri.parse(getClientsUrl)); // Fetch clients instead of warehouses
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8Body);
    } else {
      throw Exception('Failed to load Clients');
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
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClientsPage()),
              );
              if (result == true) {
                _fetchClients();
                setState(() {});
              }
            },
            child: Text('Add Client'),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchClients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<dynamic> clients = snapshot.data!;
                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      var client = clients[index];

                      return Card(
                        child: ListTile(
                          title: Text(client['name'] +
                              ' ' +
                              client[
                                  'surname']), // Display client name and surname
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Commercial Title: ${client['commercialTitle']}'),
                              Text('Phone: ${client['phone']}'),
                              Text(
                                  'Address: ${client['address']}, ${client['city']}, ${client['country']}'),
                            ],
                          ),
                          onTap: () {
                            // Handle tapping on a client item
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
