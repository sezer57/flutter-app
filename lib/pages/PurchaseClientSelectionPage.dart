import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/DebtPaymentPage2.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class PurchaseClientSelectionPage extends StatefulWidget {
  @override
  State<PurchaseClientSelectionPage> createState() =>
      _PurchaseClientSelectionPageState();
}

class _PurchaseClientSelectionPageState
    extends State<PurchaseClientSelectionPage> {
  List<dynamic> _clients = [];
  dynamic selectedClient;
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  late int totalPages;
  final int pageSize = 15; // Sayfa başına gösterilecek stok sayısı

  @override
  void initState() {
    super.initState();
    fetchClientsByPage(page).then((client) async => _clients = client);
  }

  TextEditingController searchController = TextEditingController();

  Future<List<dynamic>> fetchClientsByPage(int page) async {
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
    try {
      if (_currentPage > 0) {
        final nextPageStocks = await fetchClientsByPage(_currentPage - 1);
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
        final nextPageStocks = await fetchClientsByPage(_currentPage + 1);
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

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;
      fetchClientsByPage(_currentPage).then((stocks) async {
        setState(() {
          _clients = stocks;
        });
      });
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
            child: FutureBuilder<List<dynamic>>(
              future: fetchClientsByPage(page),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _clients.length,
                        itemBuilder: (BuildContext context, int index) {
                          final client = _clients[index];
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
                  ]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
