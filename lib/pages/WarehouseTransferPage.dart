import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/WareHousePage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/pages/SalesPage.dart';

class WarehouseTransferPage extends StatefulWidget {
  @override
  _WarehouseTransferPageState createState() => _WarehouseTransferPageState();
}

class _WarehouseTransferPageState extends State<WarehouseTransferPage> {
  TextEditingController quantityController = TextEditingController();
  List<dynamic> warehouses = [];
  List<dynamic> sourceWarehouseStocks = [];
  String? selectedSourceWarehouse;
  String? selectedTargetWarehouse;
  String? selectedStockId;
  String? DateController;
  String? quantityRemaing;
  String? quantity_type;
  var count_carton;
  var quantity;

  var sa = <String>{'Carton', 'Piece'}; //'Dozen',
  @override
  void initState() {
    super.initState();

    quantityRemaing = "0";
    fetchWarehouses();
    DateController = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
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
      //print('Failed to fetch warehouses');
    }
  }

  // Future<void> fetchStocks(String warehouseId) async {
  //   final response = await http.get(
  //       Uri.parse(
  //           'http://${await loadIP()}:8080/api/getStocksById?warehouse_id=$warehouseId'),
  //       headers: <String, String>{
  //         'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
  //       });

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       sourceWarehouseStocks = jsonDecode(utf8.decode(response.bodyBytes));
  //     });
  //   } else {
  //     // Handle API error
  //     print('Failed to fetch stocks for warehouse $warehouseId');
  //   }
  // }

  TextEditingController productController = TextEditingController();
  Future<String?> _navigateTopProductSelectionPage() async {
    if (selectedSourceWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill selectedSourceWarehouse'),
        ),
      );
    } else {
      final dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SalesPage(selectedSourceWarehouse: selectedSourceWarehouse)),
      );

      if (result != null) {
        setState(() {
          selectedStockId = result['stockId'].toString();

          if (result['type'].toString() == "Piece") ////////////////soooonnnnn
          {
            productController.text = result['stockName'] +
                " Remaing: " +
                result['quantity_remaing'].toStringAsFixed(2) +
                " " +
                result['type'].toString();
            sa = <String>{'Piece'};
            selectedUnitType = 'Piece';
          } else if (result['type'].toString() ==
              "Carton") ////////////////soooonnnnn
          {
            productController.text = result['stockName'] +
                " Remaing: " +
                result['quantity'].toStringAsFixed(2) +
                " " +
                result['type'].toString();
            sa = <String>{'Carton', 'Piece'}; //'Dozen',
            selectedUnitType = 'Carton';
          }

          count_carton = result['typeS'];
          // await fetchAndSetRemainingStock(); // Wait for remaining stock information
        });
        if (result['type'].toString() == "Piece") ////////////////soooonnnnn
        {
          sa = <String>{'Piece'};
          selectedUnitType = 'Piece';
        } else if (result['type'].toString() ==
            "Carton") ////////////////soooonnnnn
        {
          sa = <String>{'Carton', 'Piece'}; //'Dozen',
          selectedUnitType = 'Carton';
        }
      }
    }
  }

  String? selectedUnitType = 'Carton';
  //String? selectedUnit = 'Dozen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSourceWarehouse,
              onChanged: (newValue) {
                setState(() {
                  selectedSourceWarehouse = newValue;
                  selectedStockId = null;
                  // fetchStocks(newValue!);
                });
              },
              items: warehouses.map((warehouse) {
                return DropdownMenuItem<String>(
                  value: warehouse['warehouseId'].toString(),
                  child: Text(warehouse['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'From Warehouse',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: productController,
              readOnly: true, // TextField'in değiştirilemez olmasını sağlar
              decoration: InputDecoration(
                labelText: 'Choose Product',
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _navigateTopProductSelectionPage();
                  },
                ),
              ),
              onTap: () {
                _navigateTopProductSelectionPage(); // TextField'e tıklanınca da navigasyon yapılacaksa buraya ekleyebilirsiniz
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: selectedUnitType,
              items: sa.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnitType = newValue;
                  quantityController.clear();
                });
              },
              decoration: InputDecoration(labelText: 'Unit Type'),
            ),
            TextField(
              controller: quantityController,
              onChanged: (newValue) {
                setState(() {
                  quantity = newValue;
                });
              },
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTargetWarehouse,
              onChanged: (newValue) {
                setState(() {
                  selectedTargetWarehouse = newValue;
                });
              },
              items: warehouses.map((warehouse) {
                return DropdownMenuItem<String>(
                  value: warehouse['warehouseId'].toString(),
                  child: Text(warehouse['name']),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'To Warehouse',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _transfer,
              child: Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getUserNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? '';
  }

  Future<void> _transfer() async {
    if (int.parse(quantity) > 0 &&
        selectedSourceWarehouse != null &&
        selectedTargetWarehouse != null &&
        selectedStockId != null) {
      final String userName =
          await getUserNameFromSharedPreferences(); // Await here
      final Map<String, dynamic> transferData = {
        'source_id': selectedSourceWarehouse,
        'target_id': selectedTargetWarehouse,
        'stock_id': selectedStockId,
        'date': DateController,
        "quantity_type": selectedUnitType ?? 0,
        'quantity': quantity.toString(),
        'comment': "process owner:" + userName,
      };
      //print(transferData);
      final response = await http.post(
        Uri.parse('http://${await loadIP()}:8080/api/warehouseStock/transfer'),
        body: jsonEncode(transferData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        },
      );

      if (response.statusCode == 200) {
        // Handle successful transfer, for example showing a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );
        // Clear fields after successful transfer
        selectedSourceWarehouse = null;
        selectedTargetWarehouse = null;
        quantityController.clear();
        selectedStockId = null;
        Navigator.pop(context);
      } else {
        // Handle transfer failure, for example showing an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body + "ERROR")),
        );
      }
    } else {
      // Handle invalid input or missing selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please select source and target warehouses, enter a valid stock ID, enter a valid quantity'),
        ),
      );
    }
  }
}
