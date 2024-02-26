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
  final TextEditingController unitController = TextEditingController();
  final TextEditingController salesPriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController warehouseIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Automatically generate registration date
    registrationDateController.text =
        DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now());
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
            TextField(
              controller: unitController,
              decoration: InputDecoration(labelText: 'Unit'),
              keyboardType: TextInputType.number, // Only accept numbers
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
            TextField(
              controller: warehouseIdController,
              decoration: InputDecoration(labelText: 'Warehouse ID'),
              keyboardType: TextInputType.number, // Only accept numbers
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
    final String apiUrl = 'http://192.168.56.1:8080/api/stocks';

    final Map<String, dynamic> postData = {
      "registrationDate": registrationDateController.text,
      "stockName": stockNameController.text,
      "stockCode": stockCodeController.text,
      "barcode": barcodeController.text,
      "groupName": groupNameController.text,
      "middleGroupName": middleGroupNameController.text,
      "unit": int.tryParse(unitController.text) ??
          0, // Parse as int, default to 0 if parsing fails
      "salesPrice": double.parse(salesPriceController.text),
      "purchasePrice": double.parse(purchasePriceController.text),
      "warehouse_id": int.tryParse(warehouseIdController.text) ??
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
