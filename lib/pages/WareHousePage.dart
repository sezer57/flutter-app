import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/WaitingTransfer.dart';
import 'package:flutter_application_1/pages/WarehouseEditPage.dart';
import 'package:flutter_application_1/pages/WarehouseTransferPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddWarehousePage.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class WareHousePage extends StatefulWidget {
  @override
  _WareHousePageState createState() => _WareHousePageState();
}

class _WareHousePageState extends State<WareHousePage> {
  Future<List<dynamic>> _fetchWarehouses() async {
    final response = await http.get(
        Uri.parse('http://${await loadIP()}:8080/api/getWarehouse'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      final utf8Body =
          utf8.decode(response.bodyBytes); // Decode response body as UTF-8
      return jsonDecode(utf8Body);
    } else {
      return List.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouses'),
      ),
      body: Column(
        children: [
          Column(children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddWareHousePage()),
                    );
                    if (result == true) {
                      // Refresh the warehouse list if a new warehouse was added
                      setState(() {});
                    }
                  },
                  child: Text('Add Warehouse'),
                ),
                SizedBox(
                    width: 8), // Adjust the space between buttons as needed
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WarehouseTransferPage()),
                    );
                    if (result == true) {
                      // Refresh the warehouse list if a new warehouse was added
                      setState(() {});
                    }
                  },
                  child: Text('Warehouse Transfer'),
                ),
              ],
            ),
            Row(children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WaitingTransfer()),
                  );
                  if (result == true) {
                    // Refresh the warehouse list if a new warehouse was added
                    setState(() {});
                  }
                },
                child: Text('Waiting Transfers'),
              ),
            ])
          ]),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchWarehouses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<dynamic> warehouses = snapshot.data!;
                  return ListView.builder(
                    itemCount: warehouses.length,
                    itemBuilder: (context, index) {
                      var warehouse = warehouses[index];

                      return Card(
                        child: Row(children: [
                          Expanded(
                              child: ListTile(
                                  title: Text(warehouse['name']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Authorized: ${warehouse['authorized']}'),
                                      Text('Phone: ${warehouse['phone']}'),
                                      Text('Address: ${warehouse['address']}'),
                                    ],
                                  ))),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WarehouseEditPage(
                                        warehouse: warehouse)),
                              );
                              if (result == true) {
                                setState(() {
                                  _fetchWarehouses();
                                });
                              }
                            },
                          ),
                        ]),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
