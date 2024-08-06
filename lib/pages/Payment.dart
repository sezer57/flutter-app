import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/ClientsPayListPage.dart';
import 'package:flutter_application_1/pages/ClientsPurcListPage.dart';
import 'package:flutter_application_1/pages/SalesList.dart'; // Import the sales list page
import 'package:flutter_application_1/components/theme.dart';

class Payment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Payment',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to SalesClientSelectionPage.dart
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientsPayListPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_bag, color: Colors.white),
                  label: Text('Sales Payment',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 173, 37, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),
            SizedBox(height: 20), // Add space between buttons
            SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to PurchaseClientSelectionPage.dart
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientsPurcListPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text('Purchase Payment',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 173, 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),
            SizedBox(height: 20), // Add space between buttons
          ],
        ),
      ),
    );
  }
}
