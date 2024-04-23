import 'package:flutter/material.dart';

import 'package:flutter_application_1/pages/UpdateStockPage.dart';

class StockDetailesPageList extends StatelessWidget {
  final dynamic stock;

  StockDetailesPageList(this.stock);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Stock Name', stock['stock']['stockName']),
              _buildDetailItem('Stock Code', stock['stock']['stockCode']),
              _buildDetailItem('Barcode', stock['stock']['barcode']),
              _buildDetailItem('Group Name', stock['stock']['groupName']),
              _buildDetailItem(
                'Middle Group Name',
                stock['stock']['middleGroupName'],
              ),
              _buildDetailItem('Unit', stock['stock']['unit']),
              _buildDetailItem('Sales Price', stock['stock']['salesPrice']),
              _buildDetailItem(
                  'Purchase Price', stock['stock']['purchasePrice']),
              _buildDetailItem('Quantity In', stock['quantityIn']),
              _buildDetailItem('Quantity Out', stock['quantityOut']),
              _buildDetailItem(
                'Quantity Remaining',
                stock['quantityRemaining'],
              ),
              _buildDetailItem(
                'Quantity Transfer',
                stock['quantityTransfer'],
              ),
              _buildDetailItem(
                'Warehouse Name',
                stock['stock']['warehouse']['name'],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _navigateToUpdateStockPage(context);
                },
                child: Text('Update Stock'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUpdateStockPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStockForm(stock),
      ),
    );
    // Handle result if needed
  }
}
