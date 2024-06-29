import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientEditPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddClientsPage.dart';
import 'package:flutter_application_1/pages/FilterClientsPage.dart';
import 'package:flutter_application_1/pages/ClientPdfPage.dart'; // ClientPdfPage eklendi
import 'package:flutter_application_1/api/checkLoginStatus.dart';

TextEditingController searchController = TextEditingController();

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<dynamic> _clients = [];
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  late int totalPages;
  final int pageSize = 6; // Sayfa başına gösterilecek stok sayısı

  @override
  void initState() {
    super.initState();
    // Load stocks initially
    searchController.clear();
    _fetchClients(page).then((clients) async {
      setState(() {
        _clients = clients;
      });
    });
  }

  Future<List<dynamic>> _fetchClients(int page) async {
    final url = searchController.text.isEmpty
        ? 'http://${await loadIP()}:8080/api/getClientsByPage?page=$page&size=$pageSize'
        : 'http://${await loadIP()}:8080/api/getClientsBySearch?keyword=${searchController.text}&page=$page&size=$pageSize';

    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      totalPages = jsonDecode(utf8Body)['totalPages'];
      return jsonDecode(utf8Body)['content'];
    } else {
      return List.empty();
    }
  }

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;
      _fetchClients(_currentPage).then((stocks) async {
        setState(() {
          _clients = stocks;
        });
      });
    });
  }

  void _goToPreviousPage() async {
    try {
      if (_currentPage > 0) {
        final nextPageStocks = await _fetchClients(_currentPage - 1);
        setState(() {
          _currentPage--;
          _clients = nextPageStocks;
          //    filteredStocks = stocks;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _goToNextPage() async {
    try {
      if (_currentPage + 1 < totalPages) {
        final nextPageStocks = await _fetchClients(_currentPage + 1);
        setState(() {
          //  _clients.addAll(nextPageStocks);
          //filteredStocks = _clients;
          _clients = nextPageStocks;
          _currentPage++;
        });
      } else {}
    } catch (e) {
      // Handle error
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
                    _fetchClients(page).then((clients) async {
                      setState(() {
                        clients = clients;
                      });
                    });
                  }
                },
                child: Text('Add Client'),
              ),
              SizedBox(width: 5),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: _navigateToPdfPage,
                child: Text('All Clients'),
              ),
            ],
          ),
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search Product...',
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
            child: FutureBuilder<List<dynamic>>(
              future: _fetchClients(page),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _clients.length,
                          itemBuilder: (context, index) {
                            var client = _clients[index];
                            return Card(
                              color: index % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(client['name'] +
                                          ' ' +
                                          client['surname']),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Commercial Title: ${client['commercialTitle']}'),
                                          Text('Phone: ${client['phone']}'),
                                          Text(
                                            'Address: ${client['address']}, ${client['city']}, ${client['country']}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ClientEditPage(client: client)),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          _fetchClients(page);
                                        });
                                      }
                                    },
                                  ),
                                ],
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
                      ),
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
