import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/PurchaseClientSelectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/PurchasePage.dart';

class PurchaseTestPage extends StatefulWidget {
  final dynamic selectedClient;
  final dynamic selectedStock;
  PurchaseTestPage({this.selectedClient, this.selectedStock});
  @override
  _PurchaseTestPageState createState() => _PurchaseTestPageState();
}

List<dynamic> filteredClients = [];
dynamic selectedClient;
dynamic selectedStock;
List<dynamic> warehouses = [];
String? selectedSourceWarehouse;

String? selectedStockId;

class _PurchaseTestPageState extends State<PurchaseTestPage> {
  final TextEditingController clientCodeController = TextEditingController();
  final TextEditingController DateController = TextEditingController();
  final TextEditingController commercialTitleController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gsmController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    initializeState();
    // Automatically generate registration date
    DateController.text = DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now());
  }

  Future<void> initializeState() async {
    ownerController.text = await getUserNameFromSharedPreferences();
  }

  Future<String> getUserNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  bool _validateInputs() {
    return clientCodeController.text.isNotEmpty &&
        DateController.text.isNotEmpty &&
        commercialTitleController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        stockController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        ownerController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        gsmController.text.isNotEmpty;
  }

  void _clearTextFields() {
    clientCodeController.clear();
    DateController.clear();
    commercialTitleController.clear();
    nameController.clear();
    stockController.clear();
    quantityController.clear();
    ownerController.clear();
    priceController.clear();
    phoneController.clear();
    gsmController.clear();
  }

  void _navigateTopProductSelectionPage() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PurchasePage(selectedSourceWarehouse: selectedSourceWarehouse)),
    );
    if (result != null) {
      setState(() {
        selectedStock = result;
        stockController.text = selectedStock['stockName'] ?? '';
      });
    }
  }

  void _navigateToClientSelectionPage() async {
    final dynamic result1 = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PurchaseClientSelectionPage()),
    );
    if (result1 != null) {
      setState(() {
        selectedClient = result1;
        commercialTitleController.text =
            selectedClient['name'] + " " + selectedClient['surname'] ?? '';
      });
    }
  }

  Future<void> fetchWarehouses() async {
    final response = await http.get(
        Uri.parse('http://104.248.42.73:8080/api/getWarehouse'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

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
        title: Text('Purchase'),
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
                decoration: InputDecoration(labelText: 'Seller'),
                onTap: _navigateToClientSelectionPage,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSourceWarehouse,
                onChanged: (newValue) {
                  setState(() {
                    selectedSourceWarehouse = newValue;
                    selectedStockId = selectedSourceWarehouse;
                  });
                },
                items: warehouses.map((warehouse) {
                  return DropdownMenuItem<String>(
                    value: warehouse['warehouseId'].toString(),
                    child: Text(warehouse['name']),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Which Warehouse',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Product'),
                onTap: _navigateTopProductSelectionPage,
              ),
              SizedBox(height: 16),
              TextField(
                controller: quantityController,
                onChanged: (newValue) {
                  setState(() {
                    priceController.text = (double.parse(newValue!) *
                            selectedStock['purchasePrice'])
                        .toString();
                  });
                },
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              TextField(
                controller: ownerController,
                decoration: InputDecoration(labelText: 'Process owner'),
                enabled: false,
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  int quantity = int.tryParse(quantityController.text) ?? 0;
                  double price = double.tryParse(priceController.text) ?? 0.0;
                  print(selectedStock);
                  purchaseStock(selectedStock['stockId'], quantity, price,
                      selectedClient['clientId']);
                },
                child: Text('Purchase'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> purchaseStock(
      int stockCode, int quantity, double price, int clientId) async {
    final response = await http.post(
      Uri.parse('http://104.248.42.73:8080/api/purchase'),
      body: json.encode({
        "stockCode": stockCode,
        "quantity": quantity,
        "price": price,
        "clientId": clientId,
        "date": DateFormat('yyyy-MM-ddTHH:mm').format(DateTime.now()),
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );

    if (response.statusCode == 200) {
      // Purchase successful, show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase successful!'),
        ),
      );
      Navigator.pop(context);
    } else {
      // Purchase failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete purchase'),
        ),
      );
    }
  }
}
