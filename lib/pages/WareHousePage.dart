import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/WaitingTransfer.dart';
import 'package:flutter_application_1/pages/WarehouseTransferPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddWarehousePage.dart';

class WareHousePage extends StatefulWidget {
  @override
  _WareHousePageState createState() => _WareHousePageState();
}

class _WareHousePageState extends State<WareHousePage> {
  final String getWarehouseUrl = 'http://192.168.1.105:8080/api/getWarehouse';

  Future<List<dynamic>> _fetchWarehouses() async {
    final response = await http.get(Uri.parse(getWarehouseUrl));
    if (response.statusCode == 200) {
      final utf8Body =
          utf8.decode(response.bodyBytes); // Decode response body as UTF-8
      return jsonDecode(utf8Body);
    } else {
      throw Exception('Failed to load Warehouses');
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
                        child: ListTile(
                          title: Text(warehouse['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Authorized: ${warehouse['authorized']}'),
                              Text('Phone: ${warehouse['phone']}'),
                              Text('Address: ${warehouse['address']}'),
                            ],
                          ),
                          onTap: () {
                            // Handle tapping on a warehouse item
                          },
                        ),
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
