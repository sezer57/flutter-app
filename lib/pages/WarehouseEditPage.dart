import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class WarehouseEditPage extends StatefulWidget {
  final dynamic warehouse;

  WarehouseEditPage({required this.warehouse});

  @override
  _WarehouseEditPageState createState() => _WarehouseEditPageState();
}

class _WarehouseEditPageState extends State<WarehouseEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _authorizedController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _copyProducts = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse['name']);
    _authorizedController =
        TextEditingController(text: widget.warehouse['authorized']);
    _phoneController = TextEditingController(text: widget.warehouse['phone']);
    _addressController =
        TextEditingController(text: widget.warehouse['address']);
  }

  Future<void> _updateWarehouse() async {
    final response = await http.put(
      Uri.parse(
          'http://${await loadIP()}:8080/api/warehouse/${_copyProducts ? 'true' : 'false'}/${widget.warehouse["warehouseId"]}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
      body: json.encode(<String, String>{
        'name': _nameController.text,
        'authorized': _authorizedController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Warehouse update to Successful')),
      );
    } else {
      // Handle the error accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update warehouse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Warehouse',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Warehouse Name'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _authorizedController,
              decoration: InputDecoration(labelText: 'Authorized'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _copyProducts,
                  onChanged: (bool? value) {
                    setState(() {
                      _copyProducts = value!;
                    });
                  },
                ),
                Flexible(
                  child: Text(
                    'Copy the products currently in stock to this warehouse',
                    overflow: TextOverflow
                        .visible, // or ellipsis or clip as per your design
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _updateWarehouse,
              child: Text('Update Warehouse'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteWarehouse();
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

  void deleteWarehouse() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this warehouse?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                deletewarehouse();
                // print('Warehouse deleted successfully');
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletewarehouse() async {
    final response = await http.post(
      Uri.parse('http://${await loadIP()}:8080/api/deleteWarehouse'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
      body:
          jsonEncode(<String, dynamic>{'id': widget.warehouse['warehouseId']}),
    );
    Navigator.pop(context, true);
  }
}
