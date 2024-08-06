import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    //  scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
    // scaffoldBackgroundColor: Color(0xFFe6edf7),
    scaffoldBackgroundColor: Color.fromARGB(255, 241, 241, 241),
    inputDecorationTheme: InputDecorationTheme(
      // contentPadding: const EdgeInsets.all(100),
      fillColor: Colors.white,
      filled: true,
      labelStyle: GoogleFonts.dmSans(
          fontWeight: FontWeight.w500, color: Color.fromARGB(255, 59, 58, 58)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color.fromARGB(255, 75, 75, 75)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color.fromARGB(255, 75, 75, 75)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color.fromARGB(255, 75, 75, 75)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        backgroundColor: Color(0xFF004AAD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 8, 96, 210),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 10, 107, 233),
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFF2e446b),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
