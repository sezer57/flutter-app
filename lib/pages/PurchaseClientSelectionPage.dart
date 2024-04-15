import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/PurchasePage.dart';

class PurchaseClientSelectionPage extends StatefulWidget {
  @override
  State<PurchaseClientSelectionPage> createState() =>
      _PurchaseClientSelectionPageState();
}

class _PurchaseClientSelectionPageState
    extends State<PurchaseClientSelectionPage> {
  List<dynamic> warehouse = [];
  List<dynamic> filteredWarehouse = [];
  dynamic selectedClient;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.105:8080/api/getWarehouse'));
    if (response.statusCode == 200) {
      setState(() {
        warehouse = json.decode(response.body);
        filteredWarehouse = List.from(warehouse);
      });
    } else {
      print("_PurchaseClientSelectionPageState empty");
    }
  }

  void searchClients(String query) {
    setState(() {
      filteredWarehouse = warehouse.where((Warehouse) {
        final clientName = Warehouse['commercialTitle'].toString().toLowerCase();
        return clientName.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Warehouse'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search clients...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
            onChanged: searchClients,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredWarehouse.length,
              itemBuilder: (BuildContext context, int index) {
                final Warehouse = filteredWarehouse[index];
                return Card(
                    child: ListTile(
                  title: Text(Warehouse['name']), // Display client name and surname
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Authorized: ${Warehouse['authorized']}'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      selectedClient = Warehouse;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PurchasePage(selectedClient: selectedClient),
                      ),
                    );
                  },
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
