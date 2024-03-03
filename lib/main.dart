import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientSelectionPage.dart';
import 'package:flutter_application_1/pages/ClientsPage.dart';
import 'package:flutter_application_1/pages/HomePage.dart';
import 'package:flutter_application_1/pages/BottomNavBarLayout.dart';
import 'package:flutter_application_1/pages/Invoice.dart';
import 'package:flutter_application_1/pages/SettingsPage.dart';
import 'package:flutter_application_1/pages/StockPage.dart';
import 'package:flutter_application_1/pages/WareHousePage.dart';
import 'package:flutter_application_1/pages/ProductPage.dart';
import 'package:flutter_application_1/pages/WaitingTransfer.dart';

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

                      case 1:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WareHousePage()),
                        );

                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClientsPage()),
                        );

                      case 3:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StockPage()),
                        );

                      case 4:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InvoicePage()),
                        );
                      case 5:
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WaitingTransfer()),
                        );

                      default:
                      // Do nothing or handle default case
                    }
                  },
                ),
                ProductPage(),
                WareHousePage(),
                ClientsPage(),
                StockPage(),
                ClientSelectionPage()
              ],
            ),
          );
        },
      ),
    );
  }
}
