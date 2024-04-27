import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientsPayListPage.dart';
import 'package:flutter_application_1/pages/ClientsPurcListPage.dart';
import 'package:flutter_application_1/pages/SalesList.dart'; // Import the sales list page

class Payment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to SalesClientSelectionPage.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientsPayListPage(),
                  ),
                );
              },
              icon: Icon(Icons.shopping_bag),
              label: Text('Sales Payment'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 20), // Add space between buttons

            ElevatedButton.icon(
              onPressed: () {
                // Navigate to SalesListPage.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesList(),
                  ),
                );
              },
              icon: Icon(Icons.list),
              label: Text('Sales List'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.orange), // You can change color as desired
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 20), // Add space between buttons
            
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to PurchaseClientSelectionPage.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientsPurcListPage(),
                  ),
                );
              },
              icon: Icon(Icons.shopping_cart),
              label: Text('Purchase Payment'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 20), // Add space between buttons

          ],
        ),
      ),
    );
  }
}
