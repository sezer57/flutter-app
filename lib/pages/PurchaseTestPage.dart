import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class PurchaseTestPage extends StatefulWidget {
  @override
  _PurchaseTestPageState createState() => _PurchaseTestPageState();
}

List<dynamic> filteredClients = [];
dynamic selectedClient;

class _PurchaseTestPageState extends State<PurchaseTestPage> {
  final TextEditingController clientCodeController = TextEditingController();
  final TextEditingController DateController = TextEditingController();
  final TextEditingController commercialTitleController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gsmController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Automatically generate registration date
    DateController.text = DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now());
  }

  bool _validateInputs() {
    return clientCodeController.text.isNotEmpty &&
        DateController.text.isNotEmpty &&
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
    DateController.clear();
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
      appBar: AppBar(
        title: Text('Add Client'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: DateController,
                decoration: InputDecoration(labelText: 'Date'),
                keyboardType: TextInputType.datetime,
                enabled: false,
              ),
              SizedBox(height: 16),
              TextField(
                controller: commercialTitleController,
                decoration: InputDecoration(labelText: 'Alınan kişi'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Hangi Bayi'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(labelText: 'Alınan ürün'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Miktar'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: 'Alan kişi(otm)'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Fiyat'),
              ),

              SizedBox(height: 32),
              //   ElevatedButton(
              //      onPressed: ,
              //     child: Text('Submit'),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
