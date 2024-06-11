import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/pages/SignupPage.dart';
import 'package:flutter_application_1/api/settings.dart'; // SettingsPage dosyasını import edin
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    String username = usernameController.text;
    String password = passwordController.text;
    var response = await http.post(
      Uri.parse('http://${await loadIP()}:8080/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Successful login, handle tokenvar responseBody = response.body;

      // Split the response into token and name parts based on semicolon (;)
      List<String> parts = response.body.split(';');
      String token = parts[0];
      String name = parts[1];

      // Save token and name to local storage
      await saveTokenAndName(token, name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login success'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );

      // Navigate to next page or perform other actions
    } else {
      // Login failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Login failed. Error: ${response.statusCode} ${response.body}'),
        ),
      );

      // Show error dialog or message
    }
  }

  Future<void> saveTokenAndName(String token, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('name', name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupPage(),
                        ),
                      );
                    },
                    child: Text('Signup'),
                  ),
                  SizedBox(height: 120),
                  Text(
                    "KeyaCode Software Services",
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'BrushScriptMT',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
