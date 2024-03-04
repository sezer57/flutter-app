import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalesList extends StatefulWidget {
  @override
  _SalesListState createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {
  List<dynamic> purchases = [];

  @override
  void initState() {
    super.initState();
    fetchSaless();
  }

  Future<void> fetchSaless() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.105:8080/api/getSales'),
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = json.decode(response.body);
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
          );
        },
      ),
    );
  }
}
