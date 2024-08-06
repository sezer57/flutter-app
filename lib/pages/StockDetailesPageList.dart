import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/UpdateStockPage.dart';

class StockDetailesPageList extends StatelessWidget {
  final dynamic stock;

  StockDetailesPageList(this.stock);

  Widget _buildDetailItem(String label, dynamic value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Color.fromARGB(255, 174, 174, 174),
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8.0),
              Text(
                value.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(List<Widget> children) {
    return Row(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Stock Details',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow([
                _buildDetailItem('Stock Name', stock['stock']['stockName']),
                _buildDetailItem('Stock Code', stock['stock']['stockCode']),
              ]),
              _buildDetailRow([
                _buildDetailItem('Barcode', stock['stock']['barcode']),
                _buildDetailItem('Group Name', stock['stock']['groupName']),
              ]),
              _buildDetailRow([
                _buildDetailItem(
                  'Middle Group Name',
                  stock['stock']['middleGroupName'],
                ),
                _buildDetailItem('Unit', stock['stock']['unit']),
              ]),
              _buildDetailRow([
                _buildDetailItem('Sales Price', stock['stock']['salesPrice']),
                _buildDetailItem(
                    'Purchase Price', stock['stock']['purchasePrice']),
              ]),
              _buildDetailRow([
                _buildDetailItem('Quantity In', stock['quantityIn']),
                _buildDetailItem('Quantity Out', stock['quantityOut']),
              ]),
              _buildDetailRow([
                _buildDetailItem(
                  'Quantity Remaining',
                  stock['quantityRemaining'],
                ),
                _buildDetailItem(
                  'Quantity Transfer',
                  stock['quantityTransfer'],
                ),
              ]),
              _buildDetailRow([
                _buildDetailItem(
                  'Warehouse Name',
                  stock['stock']['warehouse']['name'],
                ),
                SizedBox(
                    width: 8), // Empty space to balance the row if necessary
              ]),
              SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToUpdateStockPage(context);
                  },
                  child: Text('Update Stock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUpdateStockPage(BuildContext context) async {
    final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStockForm(stock),
      ),
    );
    // Handle result if needed
  }
}
