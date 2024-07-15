import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientsPage.dart';
import 'package:flutter_application_1/pages/HomePage.dart';
import 'package:flutter_application_1/pages/BottomNavBarLayout.dart';
import 'package:flutter_application_1/pages/Invoice.dart';
import 'package:flutter_application_1/pages/LoginPage.dart';
import 'package:flutter_application_1/pages/NotificationsPage.dart';
import 'package:flutter_application_1/pages/PurchaseTestPage.dart';
import 'package:flutter_application_1/pages/WareHousePage.dart';
import 'package:flutter_application_1/pages/ProductPage.dart';
import 'package:flutter_application_1/pages/Payment.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/StockPage.dart';
import 'package:flutter_application_1/pages/SalesTestPage.dart';
import 'package:flutter_application_1/pages/SettingsPageProfile.dart';
import 'package:flutter_application_1/pages/Search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-STOCK & FINANCE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return Navigator(
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
                          MenuData('Sales', Icons.shopping_cart_checkout),
                          MenuData('Purchases', Icons.add_shopping_cart),
                          MenuData('Info', Icons.info),
                        ],
                        onMenuItemTap: (index) {
                          switch (index) {
                            case 0:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductPage()));
                              break;
                            case 1:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WareHousePage()));
                              break;
                            case 2:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ClientsPage()));
                              break;
                            case 3:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StockPage()));
                              break;
                            case 4:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InvoicePage()));
                              break;
                            case 5:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Payment()));
                              break;
                            case 6:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SalesTestPage()));
                              break;
                            case 7:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PurchaseTestPage()));
                              break;
                            case 8:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationsPage()));
                              break;
                            default:
                          }
                        },
                      ),
                      WareHousePage(),
                      ProductPage(),
                      ClientsPage(),
                      StockPage(),
                      SettingsPageProfile(),
                    ],
                  ),
                );
              },
            );
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
