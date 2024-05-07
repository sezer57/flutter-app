import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/LoginPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> signup() async {
    String name = nameController.text;
    String password = passwordController.text;
    String email = emailController.text;

    var response = await http.post(
      Uri.parse('http://192.168.1.102:8080/api/addNewUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'password': password,
        'email': email,
        'roles': 'User', // You can adjust roles as needed
      }),
    );

    if (response.statusCode == 200) {
      // Signup successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User added successfully '),
        ),
      );
      print('User added successfully');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      // Show success dialog or message
    } else {
      // Signup failed, show error message
      print('Signup failed: ${response.statusCode}');
      // Show error dialog or message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Signup failed. Error: ${response.statusCode} ${response.body}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Userame'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
