import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/PurchaseClientSelectionPage.dart';
import 'package:flutter_application_1/pages/PurchaseList.dart'; // Import PurchaseList.dart
import 'package:flutter_application_1/pages/Receipt.dart';
import 'package:flutter_application_1/pages/SalesClientSelectionPage.dart';
import 'package:flutter_application_1/pages/SalesList.dart'; // Import SalesList.dart
import 'package:flutter_application_1/components/theme.dart';

class InvoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Invoice',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesList(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 173, 37, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.list, color: Colors.white),
                  label: Text(
                    'Sales & Invoice List',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
            SizedBox(height: 40), // Spacer
            SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseList(),
                      ),
                    );
                  },
                  icon: Icon(Icons.list, color: Colors.white),
                  label: Text(
                    'Purchase & Invoice List',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 173, 23),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),
            SizedBox(height: 40), // Spacer
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptPage(),
                    ),
                  );
                },
                icon: Icon(Icons.receipt, color: Colors.white),
                label: Text(
                  'Receipt List',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 52, 173),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
