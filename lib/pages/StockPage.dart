import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/UpdateStockPage.dart';
import 'package:flutter_application_1/pages/StockDetailesPageList.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Eklemeyi unutmayın

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<dynamic> stocks = [];

  List<dynamic> filteredStocks = [];
  late Timer _timer;
  TextEditingController searchController = TextEditingController();
  String selectedWarehouseFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchStocks();

    // Initialize the timer and call _fetchStocks every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _fetchStocks());
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchStocks() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.102:8080/api/getWarehouseStock'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        stocks = json.decode(utf8.decode(response.bodyBytes));
        filteredStocks =
            stocks; // Initialize filteredStocks with all stocks initially
        _applyWarehouseFilter();
      });
    } else {
      print("STOCKPAGEERORR");
    }
  }

  void _applyWarehouseFilter() {
    setState(() {
      if (selectedWarehouseFilter == 'All') {
        filteredStocks = stocks;
      } else {
        filteredStocks = stocks
            .where((stock) =>
                stock['warehouse']['name'] == selectedWarehouseFilter)
            .toList();
      }
    });
  }

  void searchStocks(String query) {
    setState(() {
      List<dynamic> filteredStocksBySearch = stocks.where((stock) {
        final stockName = stock['stock']['stockName'].toString().toLowerCase();
        return stockName.contains(query.toLowerCase());
      }).toList();
      filteredStocks = filteredStocksBySearch.where((stock) {
        return selectedWarehouseFilter == 'All' ||
            stock['warehouse']['name'] == selectedWarehouseFilter;
      }).toList();
    });
  }

  void _navigateToUpdateStockPage(dynamic stock) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailesPageList(stock),
      ),
    );

    if (result == true) {
      // Refresh the stock list if a new stock was added
      _fetchStocks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search stocks...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 14.0),
                    ),
                    onChanged: searchStocks,
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedWarehouseFilter,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'All',
                      child: Text('All'),
                    ),
                    ...stocks
                        .map((stock) => stock['warehouse']['name'] as String)
                        .toSet()
                        .toList()
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWarehouseFilter = newValue!;
                      _applyWarehouseFilter();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                final stock = filteredStocks[index];
                return Card(
                  color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                  child: ListTile(
                    title: Text(
                      stock['stock']['stockName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity In: ${stock['quantityIn']}',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          'Quantity Out: ${stock['quantityOut']}',
                          style: TextStyle(color: Colors.red),
                        ),
                        Text(
                          'Quantity Remaining: ${stock['quantityRemaining']}',
                          style: TextStyle(color: Colors.orange),
                        ),
                        Text(
                          'Quantity Transfer: ${stock['quantityTransfer']}',
                          style: TextStyle(
                              color: Color.fromARGB(255, 136, 112, 245)),
                        ),
                        Text(
                          'Warehouse: ${stock['warehouse']['name']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    onTap: () {
                      _navigateToUpdateStockPage(stock);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
