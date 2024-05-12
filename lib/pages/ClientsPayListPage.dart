import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/ClientsPayDoPage.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class ClientsPayListPage extends StatefulWidget {
  @override
  State<ClientsPayListPage> createState() => _ClientsPayListPageState();
}

class _ClientsPayListPageState extends State<ClientsPayListPage> {
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];
  dynamic selectedClient;
  TextEditingController searchController = TextEditingController();
  int page = 0;

  @override
  void initState() {
    super.initState();
    fetchClientsByPage(page);
  }

  Future<void> fetchClientsByPage(int page) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.122:8080/api/getClientsByPage?page=$page'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(utf8.decode(response.bodyBytes));
        filteredClients = List.from(clients);
      });
    } else {
      print("Failed to fetch clients");
    }
  }

  void goToPreviousPage() {
    if (page > 0) {
      setState(() {
        page--;
      });
      fetchClientsByPage(page);
    }
  }

  void goToNextPage() {
    if (filteredClients.length >= 10) {
      setState(() {
        page++;
      });
      fetchClientsByPage(page);
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchClients,
            ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientsPayDoPage(selectedClient: selectedClient),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: goToPreviousPage,
                icon: Icon(Icons.arrow_back),
              ),
              Text('Page ${page + 1}'),
              IconButton(
                onPressed: goToNextPage,
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
