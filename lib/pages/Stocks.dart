import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:flutter_application_1/pages/AddProductPage.dart';
import 'package:flutter_application_1/pages/StockPage.dart';

class Stocks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1e84b5),
        title: Text(
          'Stocks',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockPage(),
                  ),
                );
              },
              icon: Icon(Icons.list),
              label: Text('Stocks List'),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.orange),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(fontSize: 18),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
