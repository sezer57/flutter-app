import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class PurchaseClientSelectionPage extends StatefulWidget {
  @override
  State<PurchaseClientSelectionPage> createState() =>
      _PurchaseClientSelectionPageState();
}

class _PurchaseClientSelectionPageState
    extends State<PurchaseClientSelectionPage> {
  late Future<List<dynamic>> _clientsFuture;
  List<dynamic> _clients = [];
  dynamic selectedClient;
  int _currentPage = 0;
  late int totalPages;
  final int pageSize = 15;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientsFuture = fetchClientsByPage(_currentPage);
  }

  Future<List<dynamic>> fetchClientsByPage(int page) async {
    final url = searchController.text.isEmpty
        ? 'http://${await loadIP()}:8080/api/getClientsByPage?page=$page&size=$pageSize'
        : 'http://${await loadIP()}:8080/api/getClientsBySearch?keyword=${searchController.text}&page=$page&size=$pageSize';

    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final decodedBody = jsonDecode(utf8Body);
      totalPages = decodedBody['totalPages'];
      return decodedBody['content'];
    } else {
      return List.empty();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _clientsFuture = fetchClientsByPage(_currentPage);
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _clientsFuture = fetchClientsByPage(_currentPage);
      });
    }
  }

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;
      _clientsFuture = fetchClientsByPage(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Select Client',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 12),
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
            child: FutureBuilder<List<dynamic>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No clients found'));
                } else {
                  _clients = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _clients.length,
                          itemBuilder: (BuildContext context, int index) {
                            final client = _clients[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                    client['name'] + ' ' + client['surname']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Commercial Title: ${client['commercialTitle']}'),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedClient = client;
                                  });
                                  Navigator.pop(context, selectedClient);
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
                            onPressed: _goToPreviousPage,
                            icon: Icon(Icons.arrow_back),
                          ),
                          Text('Page ${_currentPage + 1}'),
                          IconButton(
                            onPressed: _goToNextPage,
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ],
                      )
                    ],
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
