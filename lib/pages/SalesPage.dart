import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class SalesPage extends StatefulWidget {
  final String? selectedSourceWarehouse;
  SalesPage({required this.selectedSourceWarehouse});

  @override
  State<SalesPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SalesPage> {
  List<dynamic> stocks = [];
  List<dynamic> filteredStocks = [];
  dynamic selectedStock;
  TextEditingController searchController = TextEditingController();
  int page = 0;

  @override
  void initState() {
    super.initState();
    fetchStocksByPage(page);
  }

  Future<void> fetchStocksByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.130:8080/api/getStockWithIdProductByPage?page=$page&warehouse_id=${widget.selectedSourceWarehouse}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        stocks = jsonDecode(utf8.decode(response.bodyBytes));
        filteredStocks = List.from(stocks);
      });
    } else {
      print('Failed to load stocks');
    }
  }

  void goToPreviousPage() {
    if (page > 0) {
      setState(() {
        page--;
      });
      fetchStocksByPage(page);
    }
  }

  void goToNextPage() {
    if (filteredStocks.length >= 10) {
      setState(() {
        page++;
      });
      fetchStocksByPage(page);
    }
  }

  void searchStocks(String query) {
    // Filter the list based on the query
    setState(() {
      filteredStocks = stocks.where((stock) {
        final stockName = stock['stockName'].toString().toLowerCase();
        return stockName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search stocks...',
            border: InputBorder.none,
          ),
          onChanged: searchStocks,
        ),
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
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStocks.length,
              itemBuilder: (BuildContext context, int index) {
                final stock = filteredStocks[index];
                return Card(
                  child: ListTile(
                    title: Text('Stock Name: ${stock['stockName']}'),
                    subtitle: Text('Sales Price: \$${stock['salesPrice']}' +
                        " Warehouse: ${stock['warehouse']['name']}"),
                    onTap: () {
                      setState(() {
                        selectedStock = stock;
                      });
                      Navigator.pop(context, selectedStock);
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
                onPressed: goToPreviousPage,
                icon: Icon(Icons.arrow_back),
              ),
              Text('Page ${page + 1}'),
              IconButton(
                onPressed: goToNextPage,
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
