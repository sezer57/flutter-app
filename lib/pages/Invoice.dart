import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientSelectionPage.dart';

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
            SizedBox(
              width: double.infinity, // Düğmeyi genişliği boyunca genişletir
              height: 60, // Belirlenen yükseklik
              child: ElevatedButton(
                onPressed: () {
                  // Sales Invoice düğmesine tıklanınca yapılacak işlev
                },
                child: Text('Sales Invoice'),
              ),
            ),
            SizedBox(height: 20), // Boşluk eklemek için
            SizedBox(
              width: double.infinity, // Düğmeyi genişliği boyunca genişletir
              height: 60, // Belirlenen yükseklik
              child: ElevatedButton(
                onPressed: () {
                  // Purchase Invoice düğmesine tıklanınca yapılacak işlev
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientSelectionPage(),
                    ),
                  );
                },
                child: Text('Purchase Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
