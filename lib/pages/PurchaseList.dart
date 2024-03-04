import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PurchaseList extends StatefulWidget {
  @override
  _PurchaseListState createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  List<dynamic> purchases = [];

  @override
  void initState() {
    super.initState();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.105:8080/api/getPurchases'),
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = json.decode(response.body);
        purchases.sort((a, b) => b['purchase_id'].compareTo(a['purchase_id']));
      });
    } else {
      // Handle errors
      print('Failed to fetch purchases: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase List'),
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
