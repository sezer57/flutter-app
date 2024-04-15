import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PurchasePage extends StatefulWidget {
  final dynamic selectedClient;

  PurchasePage({required this.selectedClient});
  @override
  State<PurchasePage> createState() => _SettingPageState();
}

class _SettingPageState extends State<PurchasePage> {
  List<dynamic> stocks = [];
  List<dynamic> filteredStocks = [];
  dynamic selectedStock;
  TextEditingController searchController = TextEditingController();

  String selectedWarehouseFilter = 'All';
  @override
  void initState() {
    super.initState();
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.105:8080/api/getStocks'));
    if (response.statusCode == 200) {
      setState(() {
        stocks = json.decode(response.body);
        filteredStocks = List.from(stocks);
      });
    } else {
      throw Exception('Failed to load stocks');
    }
  }

  Future<void> _fetchStocks() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.105:8080/api/getWarehouseStock'));

    if (response.statusCode == 200) {
      setState(() {
        stocks = json.decode(utf8.decode(response.bodyBytes));
        filteredStocks =
            stocks; // Initialize filteredStocks with all stocks initially
        _applyWarehouseFilter();
      });
    } else {
      throw Exception('Failed to fetch stocks');
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
      filteredStocks = stocks.where((stock) {
        final stockId = stock['stockName'].toString().toLowerCase();
        return stockId.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> purchaseStock(
      int stockCode, int quantity, double price, int clientId) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.105:8080/api/purchase'),
      body: json.encode({
        "stockCode": stockCode,
        "quantity": quantity,
        "price": price,
        "clientId": clientId,
        "date": DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now()),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Purchase successful, show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase successful!'),
        ),
      );
    } else {
      // Purchase failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete purchase'),
        ),
      );
    }
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
              itemBuilder: (BuildContext context, int index) {
                final stock = filteredStocks[index];
                return Card(
                    child: ListTile(
                  title: Text('Stock Name: ${stock['stockName']}'),
                  subtitle: Text('Sales Price: \$${stock['salesPrice']}'),
                  onTap: () {
                    setState(() {
                      selectedStock = stock;
                    });
                    _showPurchaseDialog();
                  },
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPurchaseDialog() async {
    TextEditingController quantityController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Purchase ${selectedStock['stockName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int quantity = int.tryParse(quantityController.text) ?? 0;
                double price = double.tryParse(priceController.text) ?? 0.0;
                purchaseStock(selectedStock['stockId'], quantity, price,
                    widget.selectedClient['warehouseId']);
                Navigator.of(context).pop();
              },
              child: Text('Purchase'),
            ),
          ],
        );
      },
    );
  }
}
