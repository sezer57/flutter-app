import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/LoginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final List<MenuData> menuItems;
  final Function(int) onMenuItemTap;

  HomePage({required this.menuItems, required this.onMenuItemTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: "E-Stock&Finance",
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Handle menu button press
            },
          ),
          widgetx: [
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
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.logout,
                            color: Colors.black,
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
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                0.1,
                0.4,
                0.7,
                1
              ],
                  colors: [
                Color.fromARGB(255, 241, 241, 241),
                Colors.white,
                Color.fromARGB(255, 241, 241, 241),
                Colors.white,
              ])),
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              return _buildMenuCard(
                context,
                menuItems[index].title,
                menuItems[index].icon,
                menuItems[index].description,
              );
            },
          ),
        ));
  }

  Future<String> getUserNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ??
        ''; // Return empty string if name is not found
  }

  Widget _buildMenuCard(
      BuildContext context, String title, IconData icon, String description) {
    return GestureDetector(
      onTap: () {
        int index = menuItems.indexWhere((element) => element.title == title);
        onMenuItemTap(index);
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF004AAD),
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuData {
  final String title;
  final IconData icon;
  final String description;

  MenuData(this.title, this.icon, this.description);
}
