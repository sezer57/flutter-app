import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/DebtPaymentPage2.dart';

class ClientsPurcDoPage extends StatefulWidget {
  final dynamic selectedClient;
  ClientsPurcDoPage({required this.selectedClient});
  @override
  _ClientsPurcDoPageState createState() => _ClientsPurcDoPageState();
}

class _ClientsPurcDoPageState extends State<ClientsPurcDoPage> {
  List<dynamic> purchases = [];

  @override
  void initState() {
    super.initState();
    fetchSaless();
  }

  Future<void> fetchSaless() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.105:8080/api/getPurchaseInvoiceClient?client_id=${widget.selectedClient['clientId']}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = json.decode(response.body);
        purchases.sort((a, b) => b['purchase_id'].compareTo(a['purchase_id']));
      });
    } else {
      // Handle errors
      print('Failed to fetch sales: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales List'),
      ),
      body: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (BuildContext context, int index) {
          final purchase = purchases[index];
          return ListTile(
            title: Text('Stock Name: ${purchase['stockName']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price: \$${purchase['price']}'),
                Text('Quantity: ${purchase['quantity']}'),
                Text('Date: ${purchase['date']}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DebtPaymentPage2(
                    client: widget.selectedClient,
                    initialPaymentAmount: purchase['price']
                        .toString(), // Double değeri String'e dönüştürüldü
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
