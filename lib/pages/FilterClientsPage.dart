import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/DebtPaymentPage.dart';
import 'package:flutter_application_1/components/theme.dart';
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
        Uri.parse('http://${await loadIP()}:8080/api/getClients'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(utf8.decode(response.bodyBytes));
        filteredClients = List.from(clients);
      });
    } else {}
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
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Search clients...',
      ),
      body: ListView.builder(
        itemCount: filteredClients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = filteredClients[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Color.fromARGB(255, 174, 174, 174),
                width: 1,
              ),
            ),
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
