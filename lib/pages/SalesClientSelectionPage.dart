import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/SalesPage.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class SalesClientSelectionPage extends StatefulWidget {
  @override
  State<SalesClientSelectionPage> createState() =>
      _SalesClientSelectionPageState();
}

class _SalesClientSelectionPageState extends State<SalesClientSelectionPage> {
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];
  dynamic selectedClient;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    final response = await http.get(
        Uri.parse('http://104.248.42.73:8080/api/getClients'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        clients = json.decode(response.body);
        filteredClients = List.from(clients);
        print(clients);
      });
    } else {
      print("_SalesClientSelectionPageState empty");
    }
  }

  void searchClients(String query) {
    setState(() {
      filteredClients = clients.where((client) {
        final clientName = client['commercialTitle'].toString().toLowerCase();
        return clientName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Client'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search clients...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
            onChanged: searchClients,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredClients.length,
              itemBuilder: (BuildContext context, int index) {
                final client = filteredClients[index];
                return Card(
                    child: ListTile(
                  title: Text(client['name'] +
                      ' ' +
                      client['surname']), // Display client name and surname
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commercial Title: ${client['commercialTitle']}'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectedClient = client;
                    });
                    Navigator.pop(context, selectedClient);
                  },
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
