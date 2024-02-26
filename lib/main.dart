import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientsPage.dart';
import 'package:flutter_application_1/pages/HomePage.dart';
import 'package:flutter_application_1/pages/BottomNavBarLayout.dart';
import 'package:flutter_application_1/pages/StockPage.dart';
import 'package:flutter_application_1/pages/WareHousePage.dart';
import 'package:flutter_application_1/pages/ProductPage.dart';
import 'package:flutter_application_1/pages/WarehouseTransferPage.dart';

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
      home: BottomNavBarLayout(
        pages: <Widget>[
          HomePage(
            menuItems: [
              MenuData('Products', Icons.inventory),
              MenuData('Warehouses', Icons.store),
              MenuData('Clients', Icons.people),
              MenuData('Stocks', Icons.cases_outlined),
              MenuData('Info', Icons.info),
            ],
            onMenuItemTap: (index) {
              // Handle navigation based on the index
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductPage()),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WareHousePage()),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientsPage()),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockPage()),
                  );
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WarehouseTransferPage()),
                  );
                  break;
                default:
                  // Do nothing or handle default case
                  break;
              }
            },
          ),
          WareHousePage(),
          ProductPage(),
          ClientsPage(),
          StockPage(),
          WarehouseTransferPage()
        ],
      ),
    );
  }
}
