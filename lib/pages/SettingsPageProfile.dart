import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/LoginPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class SettingsPageProfile extends StatefulWidget {
  @override
  State<SettingsPageProfile> createState() => _SettingsPageProfileState();
}

class _SettingsPageProfileState extends State<SettingsPageProfile> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserInfos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _updateProfile();
              },
              child: Text('Save Changes'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _deleteAccount();
              },
              child: Text(
                'Delete Account',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getUserInfos() async {
    String? token = await getTokenFromLocalStorage();
    final response = await http.get(
        Uri.parse('http://${await loadIP()}:8080/api/getUserInfos'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    //print(response);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      _usernameController.text = data['name'];
      _emailController.text = data['email'];
      //print(data);
    } else {
      // print('Failed to get user info');
    }
  }

  void _updateProfile() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    String? token = await getTokenFromLocalStorage();
    String url =
        'http://${await loadIP()}:8080/api/editUsername'; // Örnek bir URL
    var headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var body = jsonEncode({'info1': username, 'info2': email});

    var response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"' +
              username +
              '" Profile updated successfully , You need to Again Login'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
      //print('Profile updated successfully');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
        ),
      );
      // print('Failed to update profile');
    }
  }

  void _deleteAccount() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Kullanıcı onayladı
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Kullanıcı vazgeçti
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      String? token = await getTokenFromLocalStorage();
      String url =
          'http://${await loadIP()}:8080/api/deleteAccount'; // Örnek bir URL
      var headers = <String, String>{
        'Authorization': 'Bearer $token',
      };

      var response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account deleted successfully'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );

        //print('Account deleted successfully');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account'),
          ),
        );

        //print('Failed to delete account');
      }
    } else {
      print('Operation cancelled');
    }
  }
}
