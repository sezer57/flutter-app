import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/PurchaseClientSelectionPage.dart';
import 'package:flutter_application_1/pages/PurchaseList.dart'; // Import PurchaseList.dart
import 'package:flutter_application_1/pages/Receipt.dart';
import 'package:flutter_application_1/pages/SalesClientSelectionPage.dart';
import 'package:flutter_application_1/pages/SalesList.dart'; // Import SalesList.dart

class InvoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to SalesList.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesList(),
                  ),
                );
              },
              icon: Icon(Icons.list),
              label: Text('Sales&Invoice List'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),

            SizedBox(height: 40), // Spacer

            ElevatedButton.icon(
              onPressed: () {
                // Navigate to PurchaseList.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseList(),
                  ),
                );
              },
              icon: Icon(Icons.list),
              label: Text('Purchase&Invoice List'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),

            SizedBox(height: 40), // Spacer
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to PurchaseList.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptPage(),
                  ),
                );
              },
              icon: Icon(Icons.list),
              label: Text('Receipt List'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            )

            
          ],
        ),
      ),
    );
  }
}
