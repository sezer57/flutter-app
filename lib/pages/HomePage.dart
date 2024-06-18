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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 70,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return FlexibleSpaceBar(
                  background: Container(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset(
                      'images/e-stock.jpeg',
                      height: constraints.maxHeight *
                          0.7, // Set image height based on available height
                    ),
                  ),
                );
              },
            ),
            actions: [
              Row(
                children: [
                  FutureBuilder<String>(
                    future: getUserNameFromSharedPreferences(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data ?? 'User Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0, // Maximum card width
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 1.2, // Aspect ratio of cards
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildMenuCard(
                      context, menuItems[index].title, menuItems[index].icon);
                },
                childCount: menuItems.length,
              ),
            ),
          ),
        ],
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
