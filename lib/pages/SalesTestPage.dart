import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/SalesClientSelectionPage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/SalesPage.dart';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/api/pdf_invoice_api.dart';

class SalesTestPage extends StatefulWidget {
  final dynamic selectedClient;
  final dynamic selectedStock;
  SalesTestPage({this.selectedClient, this.selectedStock});
  @override
  _SalesTestPageState createState() => _SalesTestPageState();
}

dynamic selectedClient;
dynamic selectedStock;
List<dynamic> warehouses = [];
String? selectedSourceWarehouse;

String? selectedStockId;

class _SalesTestPageState extends State<SalesTestPage> {
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
  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    initializeState();

    productprice.clear();
    productquantity.clear();
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
    return //lientCodeController.text.isNotEmpty &&
        //DateController.text.isNotEmpty &&
        commercialTitleController.text.isNotEmpty &&
            // nameController.text.isNotEmpty &&
            //     stockController.text.isNotEmpty &&
            productids.isNotEmpty &&
            productprice.isNotEmpty &&
            //  quantityController.text.isNotEmpty &&
            //  ownerController.text.isNotEmpty &&
            // priceController.text.isNotEmpty &&
            // phoneController.text.isNotEmpty &&
            VatController.text.isNotEmpty;
    //gsmController.text.isNotEmpty;
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

  var sa = <String>{'Carton', 'Dozen', 'Piece'};
  String? selectedUnitType = 'Carton';
  Future<String?> _navigateTopProductSelectionPage() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SalesPage(selectedSourceWarehouse: selectedSourceWarehouse)),
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
        selectedStock = result;
      });
      productids.add(selectedStock['stockId'].toString());
      productController.text = selectedStock['stockName'] +
          " Remaing: " +
          selectedStock['quantity'].toString() +
          " " +
          selectedStock['type'].toString();

      if (selectedStock['type'].toString() ==
          "Piece") ////////////////soooonnnnn
      {
        sa = <String>{'Piece'};
        selectedUnitType = 'Piece';
      } else if (selectedStock['type'].toString() ==
          "Carton") ////////////////soooonnnnn
      {
        sa = <String>{'Carton', 'Dozen', 'Piece'};
        selectedUnitType = 'Carton';
      }
      // await fetchAndSetRemainingStock(); // Wait for remaining stock information
    }
  }

  // Future<String> fetchAndSetRemainingStock() async {
  //   final String? remaningValue = await fetchStocksRemaing();
  //   setState(() {
  //     remaning = remaningValue;
  //     productController.text =
  //         selectedStock['stockName'] + " Remaing: " + (remaning ?? '');
  //   });
  //   return selectedStock['stockName'] + " Remaing: " + (remaning ?? '');
  // }

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

  // String? remaning;
  // Future<String?> fetchStocksRemaing() async {
  //   final response = await http.get(
  //       Uri.parse(
  //           'http://${await loadIP()}:8080/api/getStocksRemainigById?stock_id=${selectedStock['stockId']}'),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
  //       });
  //   if (response.statusCode == 200) {
  //     json.decode(response.body);

  //     return response.body;
  //   } else {
  //     //    throw Exception('Failed to load stocks');
  //   }
  // }

  TextEditingController productController = TextEditingController();

  String? selectedUnit = 'Dozen';
  TextEditingController product0Controller = TextEditingController();
  List<Map<String, dynamic>> productList =
      []; // List to store product, quantity, and price data
  List<String> productids = [];
  List<String> productprice = [];
  late String productvat;
  List<String> productquantity = [];
  List<String> productquantity_types = [];

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
                readOnly: true,
                controller: commercialTitleController,
                decoration: InputDecoration(
                  labelText: 'Buyer',
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
              if (productController.text.isEmpty)
                TextField(
                  controller: productController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Choose Product',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        _navigateTopProductSelectionPage().then((result) async {
                          setState(() {
                            product0Controller.text = productController.text;
                            if (productList.isEmpty) {
                              setState(() {
                                productList.add({});
                              });
                            }
                          });
                        });
                      },
                    ),
                  ),
                  onTap: () {
                    _navigateTopProductSelectionPage().then((result) async {
                      setState(() {
                        product0Controller.text = productController.text;
                        if (productList.isEmpty) {
                          setState(() {
                            productList.add({});
                          });
                        }
                      });
                    });
                  },
                ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  if (index == productList.length - 1) {
                    // Last item, show text fields to add more products
                    if (product0Controller.text.isNotEmpty) {
                      return Column(
                        children: [
                          TextField(
                            controller: productController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Product',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  setState(() {
                                    quantityController.clear();
                                    priceController.clear();
                                    productController.clear();
                                  });

                                  productids.removeLast();

                                  _navigateTopProductSelectionPage()
                                      .then((result) async {
                                    setState(() {
                                      product0Controller.text =
                                          productController.text;
                                      if (productList.isEmpty) {
                                        setState(() {
                                          productList.add({});
                                        });
                                      }
                                    });
                                  });
                                },
                              ),
                            ),
                            onTap: () {
                              productids.removeLast();
                              setState(() {
                                quantityController.clear();
                                priceController.clear();
                                productController.clear();
                              });
                              _navigateTopProductSelectionPage()
                                  .then((result) async {
                                setState(() {
                                  product0Controller.text =
                                      productController.text;
                                  if (productList.isEmpty) {
                                    setState(() {
                                      productList.add({});
                                    });
                                  }
                                });
                              });
                            },
                          ),
                          DropdownButtonFormField(
                            value: selectedUnitType,
                            items: sa
                                .map<DropdownMenuItem<String>>((String value) {
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
                                  priceController.text =
                                      (double.parse(newValue) *
                                              selectedStock['salesPrice'])
                                          .toString();
                                  productList[index]['quantity'] = newValue;

                                  productList[index]['price'] =
                                      priceController.text;
                                  productList[index]['product'] =
                                      productController.text;
                                } else if (selectedUnitType == "Dozen") {
                                  priceController.text =
                                      (double.parse(newValue) *
                                              selectedStock['salesPrice'] /
                                              12)
                                          .toString();
                                  productList[index]['quantity'] = newValue;

                                  productList[index]['price'] =
                                      priceController.text;
                                  productList[index]['product'] =
                                      productController.text;
                                } else {
                                  priceController.text =
                                      (double.parse(newValue) *
                                              selectedStock['salesPrice'] /
                                              selectedStock['typeS'])
                                          .toString();
                                  productList[index]['quantity'] = newValue;

                                  productList[index]['price'] =
                                      priceController.text;
                                  productList[index]['product'] =
                                      productController.text;
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
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                productList.add({});
                                if (quantityController.text.isNotEmpty &&
                                    priceController.text.isNotEmpty) {
                                  productquantity.add(quantityController.text);

                                  productquantity_types
                                      .add(selectedUnitType.toString());

                                  productprice.add(priceController.text);
                                  productController.clear();
                                  quantityController.clear();
                                  priceController.clear();
                                }
                                // Add an empty map to the list to show new fields
                                productController.clear();
                                product0Controller.clear();
                                quantityController.clear();
                                priceController.clear();
                              });
                            },
                            child: Text(quantityController.text.isEmpty
                                ? 'Add Product'
                                : 'Add Cart'),
                          ),
                        ],
                      );
                    }
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
              TextField(
                controller: VatController,
                decoration: InputDecoration(labelText: 'Vat'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 8),
              TextField(
                controller: ownerController,
                decoration: InputDecoration(labelText: 'Process owner'),
                enabled: false,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  int quantity = int.tryParse(quantityController.text) ?? 0;
                  double price = double.tryParse(priceController.text) ?? 0.0;

                  purchaseStock(selectedClient['clientId']);
                },
                child: Text('Sales & Print'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> purchaseStock(int clientId) async {
    if (_validateInputs()) {
      final response = await http.post(
        Uri.parse('http://${await loadIP()}:8080/api/Sales'),
        body: json.encode({
          "stockCodes":
              productids ?? 0, // Parse as int, default to 0 if parsing fails
          "quantity": productquantity ?? 0,
          "quantity_type": productquantity_types ?? 0,
          "autherized": ownerController.text,
          "price": productprice ?? 0,
          "vat": VatController.text ?? 0,
          "clientId": clientId,
          "date": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        },
      );

      if (response.statusCode == 200) {
        // Sales successful, show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sales successful!'),
          ),
        );

        productids.clear();
        productList.clear();
        productprice.clear();
        productquantity.clear();
        await createInvoice(jsonDecode(response.body));
        Navigator.pop(context);
      } else {
        // Sales failed, show error message

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
        productids.clear();
        productList.clear();
        productprice.clear();
        productquantity.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill fields'),
        ),
      );
    }
  }

  Future<void> createInvoice(dynamic sale) async {
    // InvoiceInfo oluşturma
    InvoiceInfo info = InvoiceInfo(
      number: sale['expense_id'].toString(),
      date: DateTime.now(),
      description: 'Sales Invoice for ${sale['stockName']}',
    );

    // Customer oluşturma
    Customer customer = Customer(
      name: sale['clientName'],
      address: sale['clientAdress'],
      number: sale['clientPhone'],
    );

    // Supplier oluşturma
    Supplier supplier = Supplier(
      Tel: ' +971 4 2266114',
      WhatsApp: ' +971559438444',
      POBox: 'P.O.Box 65127',
      name: 'Murshid Bazar',
      name2: 'Obaid Omayar Bldg',
      address: 'Shop No:1, Dubai, U.A.E',
    );

    List<InvoiceItem> invoiceItems = [];

    for (int i = 0; i < sale['stockName'].length; i++) {
      InvoiceItem item = InvoiceItem(
        description: 'Product: ${sale['stockName'][i]}',
        date: DateTime.now(),
        quantity: int.parse(sale['quantity'][i]),
        quantity_type: sale['quantity_type'][i],
        unitPrice:
            double.parse(sale['price'][i]) / (1 + (sale['vat'][i]) / 100),
        vat: (sale['vat'][i]) / 100, // 0.05, // Example VAT rate 5%
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
