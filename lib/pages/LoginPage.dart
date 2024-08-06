import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/textfield.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/pages/SignupPage.dart';
import 'package:flutter_application_1/api/settings.dart'; // Import SettingsPage
import 'package:flutter_application_1/components/theme.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // Successful login, handle token
      var responseBody = response.body;

      // Split the response into token and name parts based on semicolon (;)
      List<String> parts = responseBody.split(';');
      String token = parts[0];
      String name = parts[1];

      // Save token and name to local storage
      await saveTokenAndName(token, name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login success'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else {
      // Login failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Login failed. Error: ${response.statusCode} ${response.body}'),
        ),
      );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Column(children: [
                  Image.asset('images/loginlogo.png', height: 125, width: 125),
                ]),
                Spacer(),
                Container(
                  height: 268,
                  width: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/loginbackground.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Login",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    "E-Stock&Finance",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Color(0xFF004AAD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: GoogleFonts.dmSans(
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 59, 58, 58)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF004AAD)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF004AAD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF004AAD)),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.dmSans(
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 59, 58, 58)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF004AAD)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF004AAD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF004AAD)),
                      ),
                      suffixIcon: Icon(Icons.lock, color: Color(0xFF004AAD)),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF004AAD),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 16.1,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Not registered yet? Sign up here.',
                        style: GoogleFonts.dmSans(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      GestureDetector(
                          child: new IconButton(
                        icon: Icon(Icons.settings),
                        color: Color(0xFF004AAD),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(),
                            ),
                          );
                        },
                      )),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsPage(),
                              ),
                            );
                          },
                          child: new Text(
                            "Settings",
                            style: TextStyle(
                              color: Color(0xFF004AAD),
                              fontSize: 16,
                            ),
                          ))
                    ]),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupPage(),
                          ),
                        );
                      },
                      child: Text(
                        'If you first time using you need set up Settings.',
                        style: GoogleFonts.dmSans(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
