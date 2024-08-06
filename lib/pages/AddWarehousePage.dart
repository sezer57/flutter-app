import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class AddWareHousePage extends StatefulWidget {
  @override
  _AddWareHousePageState createState() => _AddWareHousePageState();
}

String? _ip;
@override
void initState() {
  _initialize();
}

void _initialize() async {
  _ip = await loadIP();
}

class _AddWareHousePageState extends State<AddWareHousePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController authorizedController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController userAuthoritiesController = TextEditingController();
  bool _copyProducts = false;

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
        Uri.parse(
            'http://${await loadIP()}:8080/api/${_copyProducts ? 'true' : 'false'}/warehouse'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
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
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: const Color.fromARGB(255, 255, 255, 255)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Warehouse',
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Warehouse Name'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: authorizedController,
              decoration: InputDecoration(labelText: 'Authorized'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: userAuthoritiesController,
              decoration: InputDecoration(labelText: 'User Authorities'),
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
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _postData,
              child: Text(
                'Submit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
