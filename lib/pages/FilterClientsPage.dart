import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/DebtPaymentPage.dart';
import 'package:http/http.dart' as http;
import 'DebtPaymentPage.dart'; // Gerekli olduğu sayıda
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class FilterClientsPage extends StatefulWidget {
  @override
  _FilterClientsPageState createState() => _FilterClientsPageState();
}

class _FilterClientsPageState extends State<FilterClientsPage> {
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.122:8080/api/getClients'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(utf8.decode(response.bodyBytes));
        filteredClients = List.from(clients);
      });
    } else {
      print("FilterClientsPage empty");
    }
  }

  void searchClients(String query) {
    setState(() {
      filteredClients = clients.where((client) {
        final clientName = '${client['name']} ${client['surname']}';
        return clientName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search clients...',
            border: InputBorder.none,
          ),
          onChanged: searchClients,
        ),
      ),
      body: ListView.builder(
        itemCount: filteredClients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = filteredClients[index];
          return Card(
            child: ListTile(
              title:
                  Text('Client Name: ${client['name']} ${client['surname']}'),
              subtitle: Text('Client ID: ${client['clientId']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DebtPaymentPage(
                      client: client,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
