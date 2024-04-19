import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  final List<MenuData> menuItems;
  final Function(int) onMenuItemTap;

  HomePage({required this.menuItems, required this.onMenuItemTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Menu'),
        actions: [
          // Add a SizedBox to create space between the logout icon and the user's name
          SizedBox(width: 10),
          // Display the user's name retrieved from SharedPreferences
          FutureBuilder<String>(
            future: getUserNameFromSharedPreferences(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    snapshot.data ?? 'User Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return SizedBox(); // Return an empty SizedBox if data is not yet available
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Delete the token from SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
              // Add any additional logout logic here
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio:
                    1.2, // Adjust the aspect ratio to decrease card height
                children: menuItems.map((menu) {
                  return _buildMenuCard(context, menu.title, menu.icon);
                }).toList(),
              ),
            ),
            //   Expanded(
            //     child: Image.asset(
            //      'images/a.jpeg', // Change path to your image file
            //      fit: BoxFit.fitWidth,
            //    ),
            //  ),
          ],
        ),
      ),
    );
  }

  Future<String> getUserNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ??
        ''; // Return empty string if name is not found
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        int index = menuItems.indexWhere((element) => element.title == title);
        onMenuItemTap(index);
      },
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuData {
  final String title;
  final IconData icon;

  MenuData(this.title, this.icon);
}
