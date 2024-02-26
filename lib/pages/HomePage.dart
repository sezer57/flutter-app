import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final List<MenuData> menuItems;
  final Function(int) onMenuItemTap;

  HomePage({required this.menuItems, required this.onMenuItemTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Menu'),
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
            Expanded(
              child: Image.asset(
                'images/a.jpeg', // Change path to your image file
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
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
