import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddProductPage.dart';
import 'package:flutter_application_1/pages/StockDetailesPage.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final String getStocksUrl = 'http://192.168.1.105:8080/api/getStocks';

  Future<List<dynamic>> _fetchStocks() async {
    final response = await http.get(Uri.parse(getStocksUrl));
    if (response.statusCode == 200) {
      final utf8Body =
          utf8.decode(response.bodyBytes); // Decode response body as UTF-8
      return jsonDecode(utf8Body);
    } else {
      throw Exception('Failed to load stocks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle adding new stock
              // Navigate to add stock page or show a dialog for adding stock
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddStockPage()),
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
              SizedBox(width: 8), // Add some spacing between buttons
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddStockPage()),
                  );
                  if (result == true) {
                    // Refresh the stock list if a new stock was added
                    setState(() {
                      _fetchStocks();
                    });
                  }
                },
                child: Text('Filter Warehouse'),
              ),
            ],
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
                  List<dynamic> stocks = snapshot.data!;
                  return ListView.builder(
                    itemCount: stocks.length,
                    itemBuilder: (context, index) {
                      var stock = stocks[index];
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StockDetailsPage(
                                    stock)), // Pass the selected stock to StockDetailsPage
                          );
                        },
                      ));
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
