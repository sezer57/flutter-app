import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/SalesPage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/PurchaseClientSelectionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/PurchasePage.dart';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/api/pdf_invoice_api.dart';

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

//'Dozen',

class _PurchaseTestPageState extends State<PurchaseTestPage> {
  final TextEditingController clientCodeController = TextEditingController();
  final TextEditingController DateController = TextEditingController();
  final TextEditingController VatController = TextEditingController();
  final TextEditingController commercialTitleController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gsmController = TextEditingController();
  String? selectedUnitType;
  var sa = <String>{'Carton', 'Piece'};
  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    initializeState();
    // Automatically generate registration date
    DateController.text =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
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
    if (result == null) {
      return null;
    }
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
    if (selectedStock['type'].toString() == "Piece") ////////////////soooonnnnn
    {
      sa = <String>{'Piece'};
      selectedUnitType = sa.first;
    } else if (selectedStock['type'].toString() ==
        "Carton") ////////////////soooonnnnn
    {
      sa = <String>{'Carton', 'Piece'}; //'Dozen',
      selectedUnitType = sa.first;
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
        Uri.parse('http://${await loadIP()}:8080/api/getWarehouse'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      setState(() {
        warehouses = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // Handle API error
    }
  }

  List<Map<String, dynamic>> productList =
      []; // List to store product, quantity, and price data
  List<String> productids = [];
  List<String> productprice = [];
  List<String> productquantity = [];
  List<String> productquantity_types = [];
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
                readOnly: true,
                controller: commercialTitleController,
                decoration: InputDecoration(
                  labelText: 'Seller',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      _navigateToClientSelectionPage();
                    },
                  ),
                ),
                onTap: () {
                  _navigateToClientSelectionPage();
                },
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
                          readOnly: true,
                          controller: stockController,
                          decoration: InputDecoration(
                            labelText: 'Product',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                if (stockController.text.isEmpty) {
                                  _navigateTopProductSelectionPage()
                                      .then((result) async {
                                    productList[index]['product'] =
                                        stockController.text;
                                  });
                                } else {
                                  setState(() {
                                    stockController.clear();
                                    quantityController.clear();
                                    priceController.clear();
                                  });
                                  productids.removeLast();
                                  _navigateTopProductSelectionPage()
                                      .then((result) async {
                                    productList[index]['product'] =
                                        stockController.text;
                                  });
                                }
                              },
                            ),
                          ),
                          onTap: () {
                            if (stockController.text.isEmpty) {
                              _navigateTopProductSelectionPage()
                                  .then((result) async {
                                productList[index]['product'] =
                                    stockController.text;
                              });
                            } else {
                              setState(() {
                                stockController.clear();
                                quantityController.clear();
                                priceController.clear();
                              });
                              productids.removeLast();
                              _navigateTopProductSelectionPage()
                                  .then((result) async {
                                productList[index]['product'] =
                                    stockController.text;
                              });
                            }
                          },
                        ),
                        DropdownButtonFormField(
                          value: selectedUnitType,
                          items:
                              sa.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedUnitType = newValue;
                              quantityController.clear();
                              priceController.clear();
                            });
                          },
                          decoration: InputDecoration(labelText: 'Unit Type'),
                        ),
                        TextField(
                          controller: quantityController,
                          onChanged: (newValue) {
                            setState(() {
                              if (newValue.isEmpty) {
                                newValue = "0";
                              }
                              if (selectedUnitType == "Carton") {
                                priceController.text = (double.parse(newValue) *
                                        selectedStock['purchasePrice'])
                                    .toStringAsFixed(2);
                                productList[index]['quantity'] = newValue;

                                productList[index]['price'] =
                                    priceController.text;
                              }
                              // else if (selectedUnitType == "Dozen") {
                              //   priceController.text = (double.parse(newValue) *
                              //           selectedStock['purchasePrice'] /
                              //           12)
                              //       .toString();
                              //   productList[index]['quantity'] = newValue;

                              //   productList[index]['price'] =
                              //       priceController.text;
                              // }
                              else {
                                priceController.text = (double.parse(newValue) *
                                        selectedStock['purchasePrice'] /
                                        selectedStock['typeS'])
                                    .toStringAsFixed(2);
                                productList[index]['quantity'] = newValue;

                                productList[index]['price'] =
                                    priceController.text;
                              }
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
                            productquantity_types.removeAt(index);
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
                      productquantity_types.add(selectedUnitType.toString());

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
                controller: VatController,
                decoration: InputDecoration(labelText: 'Vat'),
                keyboardType: TextInputType.datetime,
              ),
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
                  //print(selectedStock);
                  purchaseStock(selectedClient['clientId']);
                },
                child: Text('Save & Print'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> purchaseStock(int clientId) async {
    final response = await http.post(
      Uri.parse('http://${await loadIP()}:8080/api/purchase'),
      body: json.encode({
        "stockCode":
            productids ?? 0, // Parse as int, default to 0 if parsing fails
        "quantity": productquantity ?? 0,
        "quantity_type": productquantity_types ?? 0,
        "price": productprice ?? 0,
        "vat": VatController.text ?? 0,
        "autherized": ownerController.text,
        "clientId": clientId,
        "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
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
      productids.clear();
      productList.clear();
      productprice.clear();
      productquantity.clear();
      await createInvoice(jsonDecode(response.body));
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

  Future<void> createInvoice(dynamic purchase) async {
    // InvoiceInfo oluşturma
    // Örnek olarak, her satın alma için aynı fatura bilgilerini kullanıyoruz
    InvoiceInfo info = InvoiceInfo(
      number: purchase['purchase_id'].toString(),
      date: DateTime.now(),
      description: 'Purchase Invoice for ${purchase['stockName']}',
    );

    // Supplier oluşturma (Varsayılan değerler kullanıldı, isteğe bağlı olarak değiştirilebilir)
    Supplier supplier = Supplier(
      Tel: ' +971 4 2266114',
      WhatsApp: ' +971559438444',
      POBox: 'P.O.Box 65127',
      name: 'Murshid Bazar',
      name2: 'Obaid Omayar Bldg',
      address: 'Shop No:1, Dubai, U.A.E',
    );

    // Customer oluşturma
    Customer customer = Customer(
        name: purchase['clientName'],
        address: purchase['clientAdress'],
        number: purchase['clientPhone']);

    // Item oluşturma

    List<InvoiceItem> invoiceItems = [];
    for (int i = 0; i < purchase['stockName'].length; i++) {
      InvoiceItem item = InvoiceItem(
        description: 'Product: ${purchase['stockName'][i]}',
        date: DateTime.now(),
        quantity: (purchase['quantity'][i]),
        quantity_type: purchase['quantity_type'][i],
        unitPrice: (purchase['price'][i]) / (1 + (purchase['vat'][i]) / 100),
        vat: (purchase['vat'][i]) / 100, // 0.05, // Example VAT rate 5%
      );
      invoiceItems.add(item);
    }
    // Invoice oluşturma
    Invoice invoice = Invoice(
      info: info,
      supplier: supplier,
      customer: customer,
      items: invoiceItems,
      type: "sale",
    );

    // Fatura oluşturma ve dosyayı kaydetme
    final pdfFile = await PdfInvoiceApi.generate(invoice);
    PdfApi.openFile(pdfFile);
  }
}
