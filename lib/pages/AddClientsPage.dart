import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class AddClientsPage extends StatefulWidget {
  @override
  _AddClientsPageState createState() => _AddClientsPageState();
}

class _AddClientsPageState extends State<AddClientsPage> {
  final TextEditingController clientCodeController = TextEditingController();
  final TextEditingController registrationDateController =
      TextEditingController();
  final TextEditingController commercialTitleController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gsmController = TextEditingController();
  String? _ip;
  @override
  void initState() {
    super.initState();
    _fetchClientCode();

    //  Uri.parse(
    //'http://${await loadIP()}:8080/api/getDailyMovementsOfClient?date=$selectedDate'),

    registrationDateController.text =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  }

  Future<void> _fetchClientCode() async {
    final response = await http.get(
        Uri.parse('http://${await loadIP()}:8080/api/getClientCode'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        clientCodeController.text = "C" + response.body;
      });
    } else {}
  }

  Future<void> _postData() async {
    if (_validateInputs()) {
      final Map<String, dynamic> postData = {
        "clientCode": (clientCodeController.text),
        "registrationDate": registrationDateController.text,
        "commercialTitle": commercialTitleController.text,
        "name": nameController.text,
        "surname": surnameController.text,
        "address": addressController.text,
        "country": countryController.text,
        "city": cityController.text,
        "phone": phoneController.text,
        "gsm": gsmController.text,
      };

      final response = await http.post(
        Uri.parse('http://${await loadIP()}:8080/api/clients'),
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

        // Clear text fields
        _clearTextFields();
      } else {
        // Show error notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post data. Error: ${response.statusCode}'),
          ),
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
    return clientCodeController.text.isNotEmpty &&
        registrationDateController.text.isNotEmpty &&
        commercialTitleController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        surnameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        countryController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        gsmController.text.isNotEmpty;
  }

  void _clearTextFields() {
    clientCodeController.clear();
    registrationDateController.clear();
    commercialTitleController.clear();
    nameController.clear();
    surnameController.clear();
    addressController.clear();
    countryController.clear();
    cityController.clear();
    phoneController.clear();
    gsmController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Client',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12),
              TextField(
                controller: clientCodeController,
                decoration: InputDecoration(labelText: 'Client Code'),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              SizedBox(height: 12),
              TextField(
                controller: registrationDateController,
                decoration: InputDecoration(labelText: 'Registration Date'),
                keyboardType: TextInputType.datetime,
                enabled: false,
              ),
              SizedBox(height: 12),
              TextField(
                controller: commercialTitleController,
                decoration: InputDecoration(labelText: 'Commercial Title'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(labelText: 'Surname'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: 'Country'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: gsmController,
                decoration: InputDecoration(labelText: 'GSM'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _postData,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
