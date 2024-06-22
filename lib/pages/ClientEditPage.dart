import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class ClientEditPage extends StatefulWidget {
  final dynamic client;

  ClientEditPage({this.client});

  @override
  _ClientEditPageState createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _clientCodeController = TextEditingController();
  TextEditingController _commercialTitleController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _gsmController = TextEditingController();
  TextEditingController _registrationDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientCodeController = TextEditingController(
        text: widget.client["clientCode"].toString() ?? '');
    _commercialTitleController = TextEditingController(
        text: widget.client["commercialTitle"].toString() ?? '');
    _nameController =
        TextEditingController(text: widget.client["name"].toString() ?? '');
    _surnameController =
        TextEditingController(text: widget.client["surname"].toString() ?? '');
    _addressController =
        TextEditingController(text: widget.client["address"].toString() ?? '');
    _countryController =
        TextEditingController(text: widget.client["country"].toString() ?? '');
    _cityController =
        TextEditingController(text: widget.client["city"].toString() ?? '');
    _phoneController =
        TextEditingController(text: widget.client["phone"].toString() ?? '');
    _gsmController =
        TextEditingController(text: widget.client["gsm"].toString() ?? '');
    _registrationDateController = TextEditingController(
        text: widget.client["registrationDate"].toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Client'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _commercialTitleController,
                decoration: InputDecoration(labelText: 'Commercial Title'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Surname'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(labelText: 'Country'),
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _gsmController,
                decoration: InputDecoration(labelText: 'GSM'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveClient();
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  deleteClients();
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
      ),
    );
  }

  void _saveClient() async {
    // Prepare client data
    Map<String, String> clientData = {
      "clientCode": _clientCodeController.text,
      "commercialTitle": _commercialTitleController.text,
      "name": _nameController.text,
      "surname": _surnameController.text,
      "address": _addressController.text,
      "country": _countryController.text,
      "city": _cityController.text,
      "phone": _phoneController.text,
      "gsm": _gsmController.text,
      "registrationDate": _registrationDateController.text,
    };

    // Send HTTP PUT request to update client

    var response = await http.put(
      Uri.parse(
          'http://${await loadIP()}:8080/api/clients/${widget.client["clientId"]}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}',
        'Content-Type': 'application/json'
      },
      body: json.encode(clientData),
    );

    if (response.statusCode == 200) {
      // Handle success
      Navigator.pop(context, true);
      print('Client updated successfully');
      // Optionally navigate back to previous screen or show success message
    } else {
      // Handle error
      print('Failed to update client: ${response.body}');
      // Show error message or handle accordingly
    }
  }

  Future<void> deleteclient() async {
    final response = await http.post(
      Uri.parse('http://${await loadIP()}:8080/api/clientDelete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
      body: jsonEncode(<String, dynamic>{'id': widget.client['clientId']}),
    );
    Navigator.pop(context, true);
  }

  void deleteClients() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this client?"),
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
                deleteclient();

                print('Client deleted successfully');
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
