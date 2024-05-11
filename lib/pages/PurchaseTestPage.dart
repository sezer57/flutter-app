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

  Future<String?> _navigateTopProductSelectionPage() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PurchasePage(selectedSourceWarehouse: selectedSourceWarehouse)),
    );
    selectedStock = result;
    for (int i = 0; i < productids.length; i++) {
      if (productids[i] == selectedStock['stockId'].toString()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('same selected product please change quantity'),
          ),
        );
        return null; // If you want to exit the loop after finding a match
      }
    }
    if (result != null) {
      setState(() {
        stockController.text = selectedStock['stockName'];
        productids.add(selectedStock['stockId'].toString());
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
        Uri.parse('http://192.168.1.122:8080/api/getWarehouse'),
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

  List<Map<String, dynamic>> productList =
      []; // List to store product, quantity, and price data
  List<String> productids = [];
  List<String> productprice = [];
  List<String> productquantity = [];
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
              ListView.builder(
                shrinkWrap: true,
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  if (index == productList.length - 1) {
                    // Last item, show text fields to add more products
                    return Column(
                      children: [
                        TextField(
                          controller: stockController,
                          decoration: InputDecoration(labelText: 'Product'),
                          onTap: () {
                            _navigateTopProductSelectionPage().then((result) {
                              productList[index]['product'] =
                                  stockController.text;
                            });
                          },
                        ),
                        TextField(
                          controller: quantityController,
                          onChanged: (newValue) {
                            setState(() {
                              priceController.text = (double.parse(newValue!) *
                                      selectedStock['salesPrice'])
                                  .toString();
                              productList[index]['quantity'] = newValue;

                              productList[index]['price'] =
                                  priceController.text;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Quantity'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                        ),
                        TextField(
                          controller: priceController,
                          decoration: InputDecoration(labelText: 'Price'),
                          onChanged: (value) {
                            productList[index]['price'] = value;

                            /// sadece otomatik oluşturuluyo
                          },
                        ),
                      ],
                    );
                  } else {
                    // Show selected product, quantity, and price
                    var product = productList[index];
                    return ListTile(
                      title: Text('Product: ${product['product']}'),
                      subtitle: Text(
                          'Quantity: ${product['quantity']}, Price: ${product['price']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            productList.removeAt(index);
                            productids.removeAt(index);
                            productquantity.removeAt(index);
                            productprice.removeAt(index);
                          });
                        },
                      ),
                    );
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    productList.add({});
                    if (quantityController.text.isNotEmpty &&
                        priceController.text.isNotEmpty) {
                      productquantity.add(quantityController.text);
                      productprice.add(priceController.text);
                      stockController.clear();
                      quantityController.clear();
                      priceController.clear();
                    }
                    // Add an empty map to the list to show new fields
                    stockController.clear();
                    quantityController.clear();
                    priceController.clear();
                  });
                },
                child: Text(quantityController.text.isEmpty
                    ? 'Add Product'
                    : 'Add Cart'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: ownerController,
                decoration: InputDecoration(labelText: 'Process owner'),
                enabled: false,
              ),
              SizedBox(height: 16),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  int quantity = int.tryParse(quantityController.text) ?? 0;
                  double price = double.tryParse(priceController.text) ?? 0.0;
                  print(selectedStock);
                  purchaseStock(selectedClient['clientId']);
                },
                child: Text('Purchase'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> purchaseStock(int clientId) async {
    print(productids);
    print(productquantity);
    print(productprice);
    final response = await http.post(
      Uri.parse('http://192.168.1.122:8080/api/purchase'),
      body: json.encode({
        "stockCode":
            productids ?? 0, // Parse as int, default to 0 if parsing fails
        "quantity": productquantity ?? 0,
        "price": productprice ?? 0,
        "autherized": ownerController.text,
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
