import 'package:flutter/material.dart';

class StockDetailsPage extends StatelessWidget {
  final Map<String, dynamic> stock;

  StockDetailsPage(this.stock);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registration Date: ${stock['registrationDate']}'),
            Text('Stock Name: ${stock['stockName']}'),
            Text('Stock Code: ${stock['stockCode']}'),
            Text('Barcode: ${stock['barcode']}'),
            Text('Group Name: ${stock['groupName']}'),
            Text('Middle Group Name: ${stock['middleGroupName']}'),
            Text('Unit: ${stock['unit']}'),
            Text('Sales Price: ${stock['salesPrice']}'),
            Text('Purchase Price: ${stock['purchasePrice']}'),
            Text('Warehouse Name: ${stock['warehouse']['name']}'),
          ],
        ),
      ),
    );
  }
}
