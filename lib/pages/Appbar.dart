import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final IconButton? leading;
  final List<Widget>? widgetx;

  CustomAppBar({this.title, this.leading, this.widgetx});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 2), // Yalnızca alt tarafa gölge
                ),
              ],
            ),
            child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  title.toString(),
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                leading: leading,
                actions: widgetx)));
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
