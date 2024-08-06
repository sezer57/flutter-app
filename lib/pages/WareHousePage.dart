import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/WaitingTransfer.dart';
import 'package:flutter_application_1/pages/WarehouseEditPage.dart';
import 'package:flutter_application_1/pages/WarehouseTransferPage.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/AddWarehousePage.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:google_fonts/google_fonts.dart';

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
        appBar: CustomAppBar(
          title: 'Warehouses',
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                0.1,
                0.4,
                0.7,
                1
              ],
                  colors: [
                Color.fromARGB(255, 241, 241, 241),
                Colors.white,
                Color.fromARGB(255, 241, 241, 241),
                Colors.white,
              ])),
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(
                      left: 10, top: 5, bottom: 5, right: 5),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF004AAD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
                          child: Text(
                            'Add Warehouse',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Adjust the space between buttons as needed
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF004AAD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WarehouseTransferPage()),
                            );
                            if (result == true) {
                              // Refresh the warehouse list if a new warehouse was added
                              setState(() {});
                            }
                          },
                          child: Text(
                            'Warehouse Transfer',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF004AAD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WaitingTransfer()),
                          );
                          if (result == true) {
                            // Refresh the warehouse list if a new warehouse was added
                            setState(() {});
                          }
                        },
                        child: Text(
                          'Waiting Transfers',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ])
                  ])),
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
                        padding: EdgeInsets.all(8),
                        itemCount: warehouses.length,
                        itemBuilder: (context, index) {
                          var warehouse = warehouses[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Color.fromARGB(255, 174, 174, 174),
                                width: 0,
                              ),
                            ),
                            color: Colors.white,
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
                                          Text(
                                              'Address: ${warehouse['address']}'),
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
        ));
  }
}
