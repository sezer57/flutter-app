import 'package:flutter/material.dart';

class BottomNavBarLayout extends StatefulWidget {
  final List<Widget> pages;

  const BottomNavBarLayout({Key? key, required this.pages}) : super(key: key);

  @override
  _BottomNavBarLayoutState createState() => _BottomNavBarLayoutState();
}

class _BottomNavBarLayoutState extends State<BottomNavBarLayout> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, -2), // Yalnızca üst tarafa gölge
            ),
          ],
        ),
        height: 70,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF004AAD),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Warehouse',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cases_outlined),
              label: 'Stocks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
