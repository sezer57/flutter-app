import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/SalesClientSelectionPage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/SalesClientSelectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/SalesPage.dart';

class SalesTestPage extends StatefulWidget {
  final dynamic selectedClient;
  final dynamic selectedStock;
  SalesTestPage({this.selectedClient, this.selectedStock});
  @override
  _SalesTestPageState createState() => _SalesTestPageState();
}

List<dynamic> filteredClients = [];
dynamic selectedClient;
dynamic selectedStock;
List<dynamic> warehouses = [];
String? selectedSourceWarehouse;

String? selectedStockId;

class _SalesTestPageState extends State<SalesTestPage> {
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
              SalesPage(selectedSourceWarehouse: selectedSourceWarehouse)),
    );

    if (result != null) {
      setState(() {
        selectedStock = result;
      });
      await fetchAndSetRemainingStock(); // Wait for remaining stock information
    }
  }

  Future<void> fetchAndSetRemainingStock() async {
    final String? remaningValue = await fetchStocksRemaing();
    setState(() {
      remaning = remaningValue;
      stockController.text =
          selectedStock['stockName'] + " Remaing: " + (remaning ?? '');
    });
  }

  void _navigateToClientSelectionPage() async {
    final dynamic result1 = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalesClientSelectionPage()),
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

  final String getStocksUrl =
      'http://104.248.42.73:8080/api/getStocksRemainigById?stock_id=';
  String? remaning;
  Future<String?> fetchStocksRemaing() async {
    print("object");
    final response = await http.get(
        Uri.parse('$getStocksUrl${selectedStock['stockId']}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      json.decode(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load stocks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
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
                decoration: InputDecoration(labelText: 'Buyer'),
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
                    priceController.text =
                        (double.parse(newValue!) * selectedStock['salesPrice'])
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
                  print(selectedClient);
                  purchaseStock(selectedStock['stockId'], quantity, price,
                      selectedClient['clientId']);
                },
                child: Text('Sales'),
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
      Uri.parse('http://104.248.42.73:8080/api/Sales'),
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
      // Sales successful, show confirmation message
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sales successful!'),
        ),
      );
    } else {
      // Sales failed, show error message
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  }
}
