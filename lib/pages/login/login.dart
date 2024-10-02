import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
  final email = _usernameController.text;
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    _showAlertDialog('Input Error', 'Email dan password tidak boleh kosong.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
        'password': password,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final role = data['role'];
      final name = data['name'];
      final email = data['email'];
      final id = data['id'];

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            role: role,
            name: name,
            email: email,
            id: id,
          ),
        ),
      );
    } else {
      // Try to parse error if possible, otherwise show a generic error message
      String errorMessage;
      try {
        final data = json.decode(response.body);
        errorMessage = data['error'] ?? 'Login failed. Please check your credentials.';
      } catch (e) {
        // If parsing fails (like when the response is HTML), show a simple error
        errorMessage = 'Silahkan cek ulang email atau password anda.';
      }
      _showAlertDialog('Login Gagal !', errorMessage);
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    _showAlertDialog('Error', 'Terjadi kesalahan: $e');
  }
}


  // Fungsi untuk menampilkan alert dialog
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF005ACF),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: 100,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Silahkan Login',
                            style: TextStyle(
                              color: Color(0xFF005ACF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.person, color: Color(0xFF005ACF)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF005ACF), width: 4),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Color(0xFF005ACF)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF005ACF), width: 4),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF005ACF),
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _isLoading
                ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
