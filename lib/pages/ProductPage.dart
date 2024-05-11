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
  final String getStocksUrl = 'http://192.168.1.122:8080/api/getStocks';
  @override
  void initState() {
    super.initState();
    // Load stocks initially
    _fetchStocks().then((stocks) {
      setState(() {
        _stocks = stocks;
        filteredStocks =
            stocks; // Initially, filteredStocks will be same as _stocks
      });
    });
  }

  Future<List<dynamic>> _fetchStocks() async {
    final response = await http.get(Uri.parse(getStocksUrl),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      final utf8Body =
          utf8.decode(response.bodyBytes); // Decode response body as UTF-8
      return jsonDecode(utf8Body);
    } else {
      return List.empty();
      print('Failed to load stocks');
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

  void searchStocks(String query) {
    setState(() {
      // Filter the list of stocks based on the query
      // Assuming you want to filter by stockName
      filteredStocks = _stocks
          .where((stock) =>
              stock['stockName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<dynamic> _stocks =
      []; // Add this variable to hold the original list of stocks
  List<dynamic> filteredStocks =
      []; // Add this variable to hold the filtered list of stocks

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
                      // Refresh the stock list if a new stock was added
                      setState(() {
                        _fetchStocks();
                      });
                    }
                  },
                  child: Text('Add Products'),
                ),
                SizedBox(width: 10),
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
              future: _fetchStocks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  // List<dynamic> stocks = snapshot.data!;
                  return ListView.builder(
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
