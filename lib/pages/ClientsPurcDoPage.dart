import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientsPage.dart';
import 'package:flutter_application_1/pages/DebtPaymentPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class ClientsPurcDoPage extends StatefulWidget {
  final dynamic selectedClient;
  ClientsPurcDoPage({required this.selectedClient});
  @override
  _ClientsPurcDoPageState createState() => _ClientsPurcDoPageState();
}

class _ClientsPurcDoPageState extends State<ClientsPurcDoPage> {
  List<dynamic> purchases = [];
  late Future<List<dynamic>> _stocksFuture;
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  final int pageSize = 10;
  late int totalPages;
  @override
  void initState() {
    super.initState();
    _stocksFuture = fetchPurchasesByPage(page);
  }

  Future<List<dynamic>> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://${await loadIP()}:8080/api/getPurchaseInvoiceClientByPage?page=$page&client_id=${widget.selectedClient['clientId']}&keyword=${searchController.text}&size=$pageSize'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      totalPages = jsonDecode(utf8Body)['totalPages'];
      print(jsonDecode(utf8Body)['content']);
      return jsonDecode(utf8Body)['content'];
    } else {
      return List.empty();
    }
  }

  void _goToPreviousPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _stocksFuture = fetchPurchasesByPage(_currentPage);
      });
    }
  }

  void _goToNextPage() async {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _stocksFuture = fetchPurchasesByPage(_currentPage);
      });
    }
  }

  void searchStocks(String query) {
    setState(() {
      _currentPage = 0;

      _stocksFuture = fetchPurchasesByPage(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchases List'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _stocksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No purc found'));
                } else {
                  purchases = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: purchases.length,
                          itemBuilder: (BuildContext context, int index) {
                            final purchase = purchases[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  'Stock Name: ${purchase['stockName']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Price: \$${purchase['price']}',
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Quantity: ${purchase['quantity']}',
                                    ),
                                    SizedBox(height: 4.0),
                                    Text('Date: ${purchase['date']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ))
                                  ],
                                ),
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
        ]),
      ),
    );
  }
}
