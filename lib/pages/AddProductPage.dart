import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class AddStockPage extends StatefulWidget {
  @override
  _AddStockPageState createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final TextEditingController registrationDateController =
      TextEditingController();
  final TextEditingController stockNameController = TextEditingController();
  final TextEditingController stockCodeController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController middleGroupNameController =
      TextEditingController();
  String? selectedUnit = 'Cartons';
  final TextEditingController salesPriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  List<String?> warehouseIdController = [];
  List<dynamic> warehouses = [];
  List<String> selectedWarehouseIds =
      []; // Add this variable to hold the selected warehouse IDs
  String? _ip;
  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    fetchStockCode();

    // Automatically generate registration date
    registrationDateController.text =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  }

  Future<void> fetchWarehouses() async {
    final response = await http.get(
        Uri.parse('http://${await loadIP()}:8080/api/getWarehouse'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        warehouses = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // Handle API error
    }
  }

  Future<void> fetchStockCode() async {
    final response = await http.get(
        Uri.parse('http://${await loadIP()}:8080/api/getStockCode'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        stockCodeController.text = "S" + response.body;
      });
    } else {
      // Handle API error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Products'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: registrationDateController,
              decoration: InputDecoration(labelText: 'Registration Date'),
              enabled: false, // Disable editing
            ),
            TextField(
              controller: stockNameController,
              decoration: InputDecoration(labelText: 'Stock Name'),
            ),
            TextField(
              controller: stockCodeController,
              decoration: InputDecoration(labelText: 'Stock Code'),
            ),
            TextField(
              controller: barcodeController,
              decoration: InputDecoration(labelText: 'Barcode'),
            ),
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            TextField(
              controller: middleGroupNameController,
              decoration: InputDecoration(labelText: 'Middle Group Name'),
            ),
            DropdownButtonFormField(
              value: selectedUnit,
              items: <String>['Cartons']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue;
                });
              },
              decoration: InputDecoration(labelText: 'Unit'),
            ),
            TextField(
              controller: salesPriceController,
              decoration: InputDecoration(labelText: 'Sales Price'),
              keyboardType: TextInputType.numberWithOptions(
                  decimal: true), // Accept decimal numbers
            ),
            TextField(
              controller: purchasePriceController,
              decoration: InputDecoration(labelText: 'Purchase Price'),
              keyboardType: TextInputType.numberWithOptions(
                  decimal: true), // Accept decimal numbers
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: selectedWarehouseIds.length + 1,
              itemBuilder: (context, index) {
                if (index == selectedWarehouseIds.length) {
                  // Last item, show dropdown button to add more warehouses
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButtonFormField<String>(
                      onChanged: (newValue) {
                        setState(() {
                          selectedWarehouseIds.add(newValue!);
                        });
                      },
                      items: warehouses.map((warehouse) {
                        return DropdownMenuItem<String>(
                          value: warehouse['warehouseId'].toString(),
                          child: Text(warehouse['name']),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Warehouse',
                      ),
                    ),
                  );
                } else {
                  // Show selected warehouse
                  String selectedWarehouseId = selectedWarehouseIds[index];
                  var selectedWarehouse = warehouses.firstWhere((warehouse) =>
                      warehouse['warehouseId'].toString() ==
                      selectedWarehouseId);
                  return ListTile(
                    title: Text(selectedWarehouse['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          selectedWarehouseIds.removeAt(index);
                        });
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addStock(context);
              },
              child: Text('Add Stock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addStock(BuildContext context) async {
    final String apiUrl = 'http://${await loadIP()}:8080/api/stocks';

    final Map<String, dynamic> postData = {
      "registrationDate": registrationDateController.text,
      "stockName": stockNameController.text,
      "stockCode": stockCodeController.text,
      "barcode": barcodeController.text,
      "groupName": groupNameController.text,
      "middleGroupName": middleGroupNameController.text,
      "unit": int.tryParse(selectedUnit.toString()) ??
          0, // Parse as int, default to 0 if parsing fails
      "salesPrice": double.parse(salesPriceController.text),
      "purchasePrice": double.parse(purchasePriceController.text),
      "warehouse_id": selectedWarehouseIds ??
          0, // Parse as int, default to 0 if parsing fails
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
      body: jsonEncode(postData),
    );

    if (response.statusCode == 200) {
      // Show success notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock added successfully')),
      );
      // Navigate back to previous page
      Navigator.pop(context,
          true); // Pass a result back indicating that a new stock was added
    } else {
      // Show error notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to add stock. Error: ${response.statusCode}')),
      );
    }
  }
}
