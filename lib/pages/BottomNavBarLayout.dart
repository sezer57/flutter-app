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
      body: IndexedStack(
        index: _currentIndex,
        children: widget.pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Change the color of selected label
        showUnselectedLabels: true,

        unselectedItemColor:
            Colors.grey, // Change the color of unselected label

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
    );
  }
}
