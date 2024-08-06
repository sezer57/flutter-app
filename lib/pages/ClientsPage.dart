import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/ClientEditPage.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddClientsPage.dart';
import 'package:flutter_application_1/pages/FilterClientsPage.dart';
import 'package:flutter_application_1/pages/ClientPdfPage.dart'; // ClientPdfPage eklendi
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:google_fonts/google_fonts.dart';

TextEditingController searchController = TextEditingController();

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late Future<List<dynamic>> _clientsFuture;
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
    _clientsFuture = _fetchClients(page);
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

  void _goToPreviousPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _clientsFuture = _fetchClients(_currentPage);
      });
    }
  }

  void _goToNextPage() async {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _clientsFuture = _fetchClients(_currentPage);
      });
    }
  }

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;

      _clientsFuture = _fetchClients(_currentPage);
    });
  }

  void _navigateToPdfPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PdfPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
          appBar: CustomAppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: 'Clients',
          ),
          body: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddClientsPage()),
                          );
                          if (result == true) {
                            setState(() {
                              _clientsFuture = _fetchClients(page);
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
                  )),
              SizedBox(height: 12),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
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
              SizedBox(
                height: 5,
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
                              itemBuilder: (context, index) {
                                var client = _clients[index];
                                return Card(
                                  color: index % 2 == 0
                                      ? Colors.white
                                      : Colors.white,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Color.fromARGB(255, 174, 174, 174),
                                      width: 1,
                                    ),
                                  ),
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
                                                    ClientEditPage(
                                                        client: client)),
                                          );
                                          if (result == true) {
                                            setState(() {
                                              _clientsFuture =
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
          )),
    );
  }
}
