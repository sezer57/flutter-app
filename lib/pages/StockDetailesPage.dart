import 'dart:convert';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockDetailsPage extends StatefulWidget {
  final dynamic stock;

  StockDetailsPage(this.stock);

  @override
  _StockDetailsPageState createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  TextEditingController stockNameController = TextEditingController();
  TextEditingController stockCodeController = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  TextEditingController middleGroupNameController = TextEditingController();
  TextEditingController unitTypeController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController salesPriceController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with existing values
    stockNameController.text = widget.stock['stockName'];
    stockCodeController.text = widget.stock['stockCode'];
    barcodeController.text = widget.stock['barcode'];
    groupNameController.text = widget.stock['groupName'];
    middleGroupNameController.text = widget.stock['middleGroupName'];
    unitTypeController.text = widget.stock['unitType'];
    unitController.text = widget.stock['unit'].toString();
    salesPriceController.text = widget.stock['salesPrice'].toString();
    purchasePriceController.text = widget.stock['purchasePrice'].toString();
  }

  var sa = <String>{'Carton', 'Piece'}; //'Dozen',
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: stockNameController,
              decoration: InputDecoration(labelText: 'Stock Name'),
            ),
            TextFormField(
              controller: stockCodeController,
              decoration: InputDecoration(labelText: 'Stock Code'),
            ),
            TextFormField(
              controller: barcodeController,
              decoration: InputDecoration(labelText: 'Barcode'),
            ),
            TextFormField(
              controller: groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            TextFormField(
              controller: middleGroupNameController,
              decoration: InputDecoration(labelText: 'Middle Group Name'),
            ),
            DropdownButtonFormField(
              value: unitTypeController.text,
              items: sa.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  unitTypeController.text = newValue.toString();
                  if (unitTypeController.text == 'Piece') {
                    unitController.text = '1';
                  }
                  // else if (unitTypeController.text == 'Dozen') {
                  //   unitController.text = '12';
                  // }
                  else {}
                });
              },
              decoration: InputDecoration(labelText: 'Unit Type'),
            ),
            if (unitTypeController.text == 'Carton')
              TextFormField(
                  controller: unitController,
                  decoration: InputDecoration(labelText: 'Unit ')),
            TextFormField(
              controller: salesPriceController,
              decoration: InputDecoration(labelText: 'Sales Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: purchasePriceController,
              decoration: InputDecoration(labelText: 'Purchase Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the function to update the stock details
                updateStockDetails();
              },
              child: Text('Update Stock'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                deleteStock();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 210, 27, 14), // Button color
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateStockDetails() async {
    // Extract the values from text controllers
    String stockName = stockNameController.text;

    String stockCode = stockCodeController.text;
    String barcode = barcodeController.text;
    String groupName = groupNameController.text;
    String middleGroupName = middleGroupNameController.text;

    String unit = unitController.text;
    double salesPrice = double.tryParse(salesPriceController.text) ?? 0.0;
    double purchasePrice = double.tryParse(purchasePriceController.text) ?? 0.0;

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      "stock_id": widget.stock['stockId'],
      "stockName": stockName,
      "stockCode": stockCode,
      "barcode": barcode,
      "groupName": groupName,
      "middleGroupName": middleGroupName,
      "unit": unit,
      "unitType": unitTypeController.text,
      "salesPrice": salesPrice,
      "purchasePrice": purchasePrice,
    };
    final response = await http.post(
      Uri.parse('http://${await loadIP()}:8080/api/stockUpdate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // Show a success message if the update was successful

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock details updated successfully')),
      );
      Navigator.pop(context, true);
    } else {
      // Show an error message if the update failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update stock details')),
      );
    }
  }

  Future<void> deleteStock() async {
    final response = await http.post(
      Uri.parse('http://${await loadIP()}:8080/api/productDelete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
      body: jsonEncode(<String, dynamic>{'id': widget.stock['stockId']}),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock deleted successfully')),
      );
    } else {
      // Show an error message if the deletion failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete stock')),
      );
    }
  }
}
