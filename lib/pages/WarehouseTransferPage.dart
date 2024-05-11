import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseTransferPage extends StatefulWidget {
  @override
  _WarehouseTransferPageState createState() => _WarehouseTransferPageState();
}

class _WarehouseTransferPageState extends State<WarehouseTransferPage> {
  final String transferUrl =
      'http://192.168.1.122:8080/api/warehouseStock/transfer';
  final String getStocksUrl =
      'http://192.168.1.122:8080/api/getStocksById?warehouse_id=';
  TextEditingController quantityController = TextEditingController();
  List<dynamic> warehouses = [];
  List<dynamic> sourceWarehouseStocks = [];
  String? selectedSourceWarehouse;
  String? selectedTargetWarehouse;
  String? selectedStockId;
  String? DateController;
  String? quantityRemaing;
  @override
  void initState() {
    super.initState();

    quantityRemaing = "0";
    fetchWarehouses();
    DateController = DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now());
  }

  Future<void> fetchWarehouses() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.122:8080/api/getWarehouse'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        warehouses = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // Handle API error
      print('Failed to fetch warehouses');
    }
  }

  Future<void> fetchStocks(String warehouseId) async {
    final response = await http.get(Uri.parse('$getStocksUrl$warehouseId'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        sourceWarehouseStocks = jsonDecode(utf8.decode(response.bodyBytes));
        print(sourceWarehouseStocks);
      });
    } else {
      // Handle API error
      print('Failed to fetch stocks for warehouse $warehouseId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSourceWarehouse,
              onChanged: (newValue) {
                setState(() {
                  selectedSourceWarehouse = newValue;
                  selectedStockId = null;
                  fetchStocks(newValue!);
                });
              },
              items: warehouses.map((warehouse) {
                return DropdownMenuItem<String>(
                  value: warehouse['warehouseId'].toString(),
                  child: Text(warehouse['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'From Warehouse',
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedStockId,
              onChanged: (newValue) {
                setState(() {
                  selectedStockId = newValue;
                });
              },
              items: sourceWarehouseStocks.map((stock) {
                return DropdownMenuItem<String>(
                  value: stock['stockId'].toString(),
                  child: Text(stock['stockName'] +
                      " Remaining : " +
                      stock['quantity']
                          .toString()), // Adjust this according to your stock data structure
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Stock',
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTargetWarehouse,
              onChanged: (newValue) {
                setState(() {
                  selectedTargetWarehouse = newValue;
                });
              },
              items: warehouses.map((warehouse) {
                return DropdownMenuItem<String>(
                  value: warehouse['warehouseId'].toString(),
                  child: Text(warehouse['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'To Warehouse',
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _transfer,
              child: Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getUserNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  Future<void> _transfer() async {
    final int quantity = int.tryParse(quantityController.text) ?? 0;

    if (quantity > 0 &&
        selectedSourceWarehouse != null &&
        selectedTargetWarehouse != null &&
        selectedStockId != null) {
      final String userName =
          await getUserNameFromSharedPreferences(); // Await here
      final Map<String, dynamic> transferData = {
        'source_id': selectedSourceWarehouse,
        'target_id': selectedTargetWarehouse,
        'stock_id': selectedStockId,
        'date': DateController,
        'quantity': quantity.toString(),
        'comment': "process owner:" + userName,
      };

      final response = await http.post(
        Uri.parse(transferUrl),
        body: jsonEncode(transferData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        },
      );

      if (response.statusCode == 200) {
        // Handle successful transfer, for example showing a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
        // Clear fields after successful transfer
        selectedSourceWarehouse = null;
        selectedTargetWarehouse = null;
        quantityController.clear();
        selectedStockId = null;
      } else {
        // Handle transfer failure, for example showing an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
      }
    } else {
      // Handle invalid input or missing selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please select source and target warehouses, enter a valid stock ID, enter a valid quantity'),
        ),
      );
    }
  }
}
