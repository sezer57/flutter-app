import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateStockForm extends StatefulWidget {
  final dynamic stock;
  UpdateStockForm(this.stock);

  @override
  _UpdateStockFormState createState() => _UpdateStockFormState();
}

class _UpdateStockFormState extends State<UpdateStockForm> {
  TextEditingController quantityInController = TextEditingController();
  TextEditingController quantityOutController = TextEditingController();
  TextEditingController quantityTransferController = TextEditingController();
  TextEditingController quantityRemainingController = TextEditingController();
  TextEditingController quantityReservedController = TextEditingController();
  TextEditingController quantityBlockedController = TextEditingController();
  TextEditingController usableQuantityController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with existing values
    quantityInController.text = widget.stock['quantityIn'].toString();
    quantityOutController.text = widget.stock['quantityOut'].toString();
    quantityTransferController.text =
        widget.stock['quantityTransfer'].toString();
    quantityRemainingController.text =
        widget.stock['quantityRemaining'].toString();
    quantityReservedController.text =
        widget.stock['quantityReserved'].toString();
    quantityBlockedController.text = widget.stock['quantityBlocked'].toString();
    usableQuantityController.text = widget.stock['usableQuantity'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Product Name: " + widget.stock['stock']['stockName']),
          TextField(
            controller: quantityInController,
            decoration: InputDecoration(labelText: 'Quantity In'),
          ),
          TextField(
            controller: quantityOutController,
            decoration: InputDecoration(labelText: 'Quantity Out'),
          ),
          TextField(
            controller: quantityTransferController,
            decoration: InputDecoration(labelText: 'Quantity Transfer'),
          ),
          TextField(
            controller: quantityRemainingController,
            decoration: InputDecoration(labelText: 'Quantity Remaining'),
          ),
          TextField(
            controller: quantityReservedController,
            decoration: InputDecoration(labelText: 'Quantity Reserved'),
          ),
          TextField(
            controller: quantityBlockedController,
            decoration: InputDecoration(labelText: 'Quantity Blocked'),
          ),
          TextField(
            controller: usableQuantityController,
            decoration: InputDecoration(labelText: 'Usable Quantity'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _updateQuantities();
            },
            child: Text('Update'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _deleteStock();
            },
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 210, 27, 14), // Button color
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _updateQuantities() async {
    int quantityIn = int.tryParse(quantityInController.text) ?? 0;
    int quantityOut = int.tryParse(quantityOutController.text) ?? 0;
    int quantityTransfer = int.tryParse(quantityTransferController.text) ?? 0;
    int quantityRemaining = int.tryParse(quantityRemainingController.text) ?? 0;
    int quantityReserved = int.tryParse(quantityReservedController.text) ?? 0;
    int quantityBlocked = int.tryParse(quantityBlockedController.text) ?? 0;
    int usableQuantity = int.tryParse(usableQuantityController.text) ?? 0;

    Map<String, dynamic> requestBody = {
      "stockId": widget.stock['stock']['stockId'],
      "quantityIn": quantityIn,
      "quantityOut": quantityOut,
      "quantityTransfer": quantityTransfer,
      "quantityRemaining": quantityRemaining,
      "quantityReserved": quantityReserved,
      "quantityBlocked": quantityBlocked,
      "usableQuantity": usableQuantity,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.105:8080/api/warehouseStockUpdate'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quantities updated successfully'),
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantities'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteStock() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.105:8080/api/warehouseStockDelete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.stock['stock']['stockId'], // Pass the stock id to delete
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock deleted successfully'),
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true); // Navigate back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete stock'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
