import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/PurchasePage.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/PurchaseTestPage.dart';

class PurchaseClientSelectionPage extends StatefulWidget {
  @override
  State<PurchaseClientSelectionPage> createState() =>
      _PurchaseClientSelectionPageState();
}

class _PurchaseClientSelectionPageState
    extends State<PurchaseClientSelectionPage> {
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
        Uri.parse('http://192.168.1.130:8080/api/getClients'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(utf8.decode(response.bodyBytes));
        filteredClients = List.from(clients);
        print(clients);
      });
    } else {
      print("_PurchaseClientSelectionPageState empty");
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
