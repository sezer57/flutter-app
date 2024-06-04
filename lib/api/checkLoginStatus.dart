import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Function to check login status
Future<bool> checkLoginStatus() async {
  // Retrieve the token from local storage
  String? token = await getTokenFromLocalStorage();

  // Check if the token is present and not expired
  if (token != null && await isTokenExpired(token) == false) {
    return true; // User is logged in
  } else {
    return false; // User is not logged in or token is expired
  }
}

// Function to retrieve token from local storage
Future<String?> getTokenFromLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

String? _ip;

Future<String?> loadIP() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('ip');
}

// Function to check if token is expired
Future<bool> isTokenExpired(String token) async {
  var response = await http.get(
    Uri.parse('http://${await loadIP()}:8080/api/getExpired'),
    headers: <String, String>{
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    // Token is not expired

    return false;
  } else if (response.statusCode == 403) {
    // Token is expired

    return true;
  } else {
    // Failed to determine token expiration status

    return true;
  }
}
