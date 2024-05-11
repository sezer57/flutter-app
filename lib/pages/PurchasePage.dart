import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class PurchasePage extends StatefulWidget {
  final String? selectedSourceWarehouse;
  PurchasePage({required this.selectedSourceWarehouse});
  @override
  State<PurchasePage> createState() => _SettingPageState();
}

String? selectedSourceWarehouse;

class _SettingPageState extends State<PurchasePage> {
  List<dynamic> stocks = [];
  List<dynamic> filteredStocks = [];
  dynamic selectedStock;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchStocks();
  }

  Future<void> fetchStocks() async {
    print(selectedSourceWarehouse);
    final response = await http.get(
        Uri.parse(
            'http://192.168.1.102:8080/api/getStockWithIdProduct?warehouse_id=${widget.selectedSourceWarehouse}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        stocks = jsonDecode(utf8.decode(response.bodyBytes));
        filteredStocks = List.from(stocks);
      });
    } else {
      throw Exception('Failed to load stocks');
    }
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
        //  _applyWarehouseFilter();
      });
    } else {
      throw Exception('Failed to fetch stocks');
    }
  }

  void searchStocks(String query) {
    setState(() {
      filteredStocks = stocks.where((stock) {
        final stockId = stock['stockName'].toString().toLowerCase();
        return stockId.contains(query.toLowerCase());
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
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
