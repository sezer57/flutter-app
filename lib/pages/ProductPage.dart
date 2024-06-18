import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/StockDetailesPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddProductPage.dart';

import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/ProductPdfPage.dart'; // Import PdfViewPage.dart

TextEditingController searchController = TextEditingController();

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int page = 0;

  @override
  void initState() {
    super.initState();
    // Load stocks initially
    _fetchStocksByPage(page).then((stocks) {
      setState(() {
        _stocks = stocks;
        filteredStocks =
            stocks; // Initially, filteredStocks will be same as _stocks
      });
    });
  }

  Future<List<dynamic>> _fetchStocksByPage(int page) async {
    final response = await http.get(
        Uri.parse(
            'http://${await loadIP()}:8080/api/getStocksByPage?page=$page'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      return jsonDecode(utf8Body);
    } else {
      return List.empty();
      //throw Exception('Failed to load stocks');
    }
  }

  int _currentPage = 0; // Başlangıç sayfa numarası

  Future<void> _loadNextPage() async {
    try {
      final List<dynamic> nextPageStocks =
          await _fetchStocksByPage(_currentPage);
      setState(() {
        _stocks.addAll(
            nextPageStocks); // _stocks listesine yeni sayfa ürünlerini ekler
        filteredStocks = _stocks; // Filtrelenmiş listeyi günceller
        _currentPage++; // Sayfa numarasını artırır
      });
    } catch (e) {
      // Hata durumunda uygun bir işlem yapılabilir
    }
  }

  void _navigateToUpdateStockPage(dynamic stock) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailsPage(stock),
      ),
    );
  }

  void searchStocks(String query) async {
    // Fetch all stocks from all pages
    List<dynamic> allStocks = await _fetchAllStocks();
    setState(() {
      // Filter the list of all stocks based on the query
      // Assuming you want to filter by stockName
      filteredStocks = allStocks
          .where((stock) =>
              stock['stockName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<List<dynamic>> _fetchAllStocks() async {
    List<dynamic> allStocks = [];
    int currentPage = 0;
    try {
      while (true) {
        final nextPageStocks = await _fetchStocksByPage(currentPage);
        if (nextPageStocks.isEmpty) break;
        allStocks.addAll(nextPageStocks);
        currentPage++;
      }
    } catch (e) {}
    return allStocks;
  }

  List<dynamic> _stocks =
      []; // Add this variable to hold the original list of stocks
  List<dynamic> filteredStocks =
      []; // Add this variable to hold the filtered list of stocks

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        page =
            _currentPage; // Update page variable for _fetchStocksByPage function
      });
      _fetchStocksByPage(_currentPage).then((stocks) {
        setState(() {
          _stocks = stocks;
          filteredStocks = stocks;
        });
      });
    }
  }

  void _goToNextPage() {
    // Check if there are more stocks in the next page
    if (filteredStocks.length >= 10) {
      setState(() {
        _currentPage++;
        page =
            _currentPage; // Update page variable for _fetchStocksByPage function
      });
      _fetchStocksByPage(_currentPage).then((stocks) {
        setState(() {
          _stocks = stocks;
          filteredStocks = stocks;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [],
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
                        _fetchStocksByPage(page);
                      });
                    }
                  },
                  child: Text('Add Products'),
                ),
              ],
            ),
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
            onChanged: searchStocks,
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchStocksByPage(page),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  // List<dynamic> stocks = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredStocks.length,
                          itemBuilder: (context, index) {
                            var stock = filteredStocks[index];
                            var warehouseName = stock['warehouse']['name'];
                            var salesPrice = stock['salesPrice'];
                            return Card(
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
                                onTap: () {
                                  _navigateToUpdateStockPage(stock);
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
