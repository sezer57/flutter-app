import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/LoginPage.dart';
import 'package:google_fonts/google_fonts.dart';
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
            expandedHeight: 120,
            backgroundColor: Color.fromARGB(255, 10, 107, 233),
            title: Row(
              children: [
                Image.asset(
                  'images/ic_launcher.png',
                  height: 24, // Adjust the height as needed
                  width: 24, // Adjust the width as needed
                ),
                SizedBox(width: 8.0), // Spacing between image and text
                Text(
                  'E-Stock&Finance',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Color(0xFF6fc6e4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ), // SliverAppBar color
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding:
                  EdgeInsets.only(left: 0, bottom: 13.0), // Center the title
              title: Text(
                'Revelation at finance & inventory management', // The text you want to add below the title
                style: GoogleFonts.ptSansNarrow(
                  textStyle: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            pinned: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FutureBuilder<String>(
                  future: getUserNameFromSharedPreferences(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            snapshot.data ?? 'User Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
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
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildMenuCard(
                    context,
                    menuItems[index].title,
                    menuItems[index].icon,
                  );
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
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: Color(0xFF2e446b),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2e446b),
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
