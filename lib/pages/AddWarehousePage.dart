import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddWareHousePage extends StatefulWidget {
  @override
  _AddWareHousePageState createState() => _AddWareHousePageState();
}

class _AddWareHousePageState extends State<AddWareHousePage> {
  final String url = 'http://192.168.56.1:8080/api/warehouse';
  TextEditingController nameController = TextEditingController();
  TextEditingController authorizedController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController userAuthoritiesController = TextEditingController();

  Future<void> _postData() async {
    if (_validateInputs()) {
      final Map<String, String> postData = {
        "name": nameController.text,
        "authorized": authorizedController.text,
        "phone": phoneController.text,
        "address": addressController.text,
        "userAuthorities": userAuthoritiesController.text
      };

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        // Show success notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data posted successfully')),
        );
        // Navigate back to previous page
        Navigator.pop(context,
            true); // Pass a result back indicating that a new stock was added
      } else {
        // Show error notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to post data. Error: ${response.statusCode}')),
        );
      }
    } else {
      // Show validation error notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  bool _validateInputs() {
    return nameController.text.isNotEmpty &&
        authorizedController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        userAuthoritiesController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: authorizedController,
              decoration: InputDecoration(labelText: 'Authorized'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: userAuthoritiesController,
              decoration: InputDecoration(labelText: 'User Authorities'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _postData,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
