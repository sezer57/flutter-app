import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/pages/DebtPaymentPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class ClientsPayDoPage extends StatefulWidget {
  final dynamic selectedClient;
  ClientsPayDoPage({required this.selectedClient});
  @override
  _ClientsPayDoPageState createState() => _ClientsPayDoPageState();
}

class _ClientsPayDoPageState extends State<ClientsPayDoPage> {
  List<dynamic> purchases = [];

  @override
  void initState() {
    super.initState();
    fetchSaless();
  }

  Future<void> fetchSaless() async {
    final response = await http.get(
        Uri.parse(
            'http://104.248.42.73:8080/api/getSalesInvoiceClient?client_id=${widget.selectedClient['clientId']}'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        purchases = jsonDecode(utf8.decode(response.bodyBytes));
        purchases.sort((a, b) => b['expense_id'].compareTo(a['expense_id']));
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
                  builder: (context) => DebtPaymentPage(
                    client: widget.selectedClient,
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
