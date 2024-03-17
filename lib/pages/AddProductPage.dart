import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  String? warehouseIdController;
  List<dynamic> warehouses = [];
  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    // Automatically generate registration date
    registrationDateController.text =
        DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now());
  }

  Future<void> fetchWarehouses() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.105:8080/api/getWarehouse'));

    if (response.statusCode == 200) {
      setState(() {
        warehouses = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // Handle API error
      print('Failed to fetch warehouses');
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
            DropdownButtonFormField<String>(
              onChanged: (newValue) {
                setState(() {
                  warehouseIdController = newValue;
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
    final String apiUrl = 'http://192.168.1.105:8080/api/stocks';

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
      "warehouse_id": warehouseIdController ??
          0, // Parse as int, default to 0 if parsing fails
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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
