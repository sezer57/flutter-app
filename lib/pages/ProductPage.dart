import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

import 'AddProductPage.dart';
import 'StockDetailesPage.dart';

TextEditingController searchController = TextEditingController();

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentPage = 0;
  List<dynamic> _stocks = [];
  late Future<List<dynamic>> _stocksFuture;
  final int pageSize = 6; // Sayfa başına gösterilecek stok sayısı
  late int totalPages;

  @override
  void initState() {
    super.initState();
    searchController.clear();
    _stocksFuture = _fetchStocks(_currentPage);
  }

  Future<List<dynamic>> _fetchStocks(int page) async {
    final url = searchController.text.isEmpty
        ? 'http://${await loadIP()}:8080/api/getStocksByPage?page=$page&size=$pageSize'
        : 'http://${await loadIP()}:8080/api/getStocksBySearch?keyword=${searchController.text}&page=$page&size=$pageSize';

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

  void _navigateToUpdateStockPage(dynamic stock) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailsPage(stock),
      ),
    );
    if (result == true) {
      setState(() {
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  void searchStocks(String query) {
    setState(() {
      _currentPage = 0;
      _stocksFuture = _fetchStocks(_currentPage);
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStockPage(),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _stocksFuture = _fetchStocks(_currentPage);
                      });
                    }
                  },
                  child: Text('Add Products'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
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
              onChanged: searchStocks,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _stocksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products found'));
                } else {
                  _stocks = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _stocks.length,
                          itemBuilder: (context, index) {
                            var stock = _stocks[index];
                            var warehouseName = stock['warehouse']['name'];
                            var salesPrice = stock['salesPrice'];
                            return Card(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(stock['stockName']),
                                      subtitle: Text("Code: " +
                                          stock['stockCode'] +
                                          " Price: " +
                                          salesPrice.toString() +
                                          " Warehouse: " +
                                          warehouseName +
                                          " Date: " +
                                          stock['registrationDate']),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      _navigateToUpdateStockPage(stock);
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
