import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientsPage.dart';
import 'package:flutter_application_1/pages/HomePage.dart';
import 'package:flutter_application_1/pages/BottomNavBarLayout.dart';
import 'package:flutter_application_1/pages/Invoice.dart';
import 'package:flutter_application_1/pages/ClientsPurcListPage.dart';
import 'package:flutter_application_1/pages/NotificationsPage.dart';
import 'package:flutter_application_1/pages/WareHousePage.dart';
import 'package:flutter_application_1/pages/ProductPage.dart';
import 'package:flutter_application_1/pages/Payment.dart';
import 'package:flutter_application_1/pages/Stocks.dart';
import 'package:flutter_application_1/pages/PdfViewPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => BottomNavBarLayout(
              pages: <Widget>[
                HomePage(
                  menuItems: [
                    MenuData('Products', Icons.inventory),
                    MenuData('Warehouses', Icons.store),
                    MenuData('Clients', Icons.people),
                    MenuData('Stocks', Icons.cases_outlined),
                    MenuData('Invoice', Icons.description),
                    MenuData('Payment', Icons.payment),
                    MenuData('Info', Icons.info),
                  ],
                  onMenuItemTap: (index) {
                    // Handle navigation based on the index
                    switch (index) {
                      case 0:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductPage()),
                        );
                        break; // Make sure to break after each case

                      case 1:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WareHousePage()),
                        );
                        break;

                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsPage()),
                        );
                        break;

                      case 3:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Stocks()),
                        );
                        break;

                      case 4:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InvoicePage()),
                        );
                        break;

                      case 5:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Payment()),
                        );
                        break;

                      case 6:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationsPage()),
                        );
                        break;

                      default:
                      // Do nothing or handle default case
                    }
                  },
                ),
                WareHousePage(),
                ProductPage(),
                ClientsPage(),
                Stocks(),
                NotificationsPage(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Entegre edilecek kod buradan başlıyor

class PdfPage extends StatelessWidget {
  static final String title = 'Invoice';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: PdfPage(),
      );
}
