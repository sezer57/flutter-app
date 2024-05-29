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

// Function to check if token is expired
Future<bool> isTokenExpired(String token) async {
  var response = await http.get(
    Uri.parse('http://192.168.1.130:8080/api/getExpired'),
    headers: <String, String>{
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    // Token is not expired
    print("Token is not expired");
    return false;
  } else if (response.statusCode == 403) {
    // Token is expired
    print("Token is not expired403");
    return true;
  } else {
    // Failed to determine token expiration status
    print("Token is not statusstatus");
    return true;
  }
}
