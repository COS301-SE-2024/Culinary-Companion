import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  final String edgeFunctionUrl =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/hello-world';

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Perform login logic here
      // If successful, navigate to the home screen
      loginUser(_email, _password, 'signIn');
    }
  }

  Future<void> loginUser(String email, String password, String action) async {
    try {
      final response = await http.post(
        Uri.parse(edgeFunctionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'action': action, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // Authentication successful, handle the user object as needed
        print('Login successful: ${responseBody['user']}');
        String userId = responseBody['user']['id'];

        // Save the userId to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final responseBody = jsonDecode(response.body);
        // Authentication failed, handle the error
        print('Login failed: ${responseBody['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${responseBody['error']}')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Login'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 365,
                  height: 46,
                  child: TextFormField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Email:',
                      labelStyle: TextStyle(
                        fontSize: 20, // Increase the font size as needed
                        color: Colors.white,
                      ),
                      hintText: 'example@gmail.com',
                      hintStyle: TextStyle(color: Color(0xFF778579)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust the border radius as needed
                        borderSide: BorderSide(
                          color: Color(0xFFA9B8AC), // Set the border color
                          width: 2.0, // Adjust the border thickness as needed
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Ensure the border radius matches
                        borderSide: BorderSide(
                          color: Color(
                              0xFFE2954F), // Set the border color when the field is focused
                          width: 2.0, // Adjust the border thickness as needed
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ), // Adjust padding to ensure label text sits above the border
                      filled: false, // Ensure the filled property is false
                      fillColor: Colors
                          .transparent, // Set fillColor to transparent if needed
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (value) => _email = value,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 365,
                  height: 46,
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Password:',
                      labelStyle: TextStyle(
                        fontSize: 20, // Increase the font size as needed
                        color: Colors.white,
                      ),
                      hintText: '••••••••••',
                      hintStyle: TextStyle(color: Color(0xFF778579)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust the border radius as needed
                        borderSide: BorderSide(
                          color: Color(0xFFA9B8AC), // Set the border color
                          width: 2.0, // Adjust the border thickness as needed
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            8.0), // Ensure the border radius matches
                        borderSide: BorderSide(
                          color: Color(
                              0xFFE2954F), // Set the border color when the field is focused
                          width: 2.0, // Adjust the border thickness as needed
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 12.0,
                      ), // Adjust padding to ensure label text sits above the border
                      filled: false, // Ensure the filled property is false
                      fillColor: Colors
                          .transparent, // Set fillColor to transparent if needed
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onChanged: (value) => _password = value,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: 365,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFDC945F), // Button background color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Border radius
                      ),
                      side: BorderSide(
                        color: Colors.transparent, // Border color
                        width: 2.0, // Border thickness
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.black, // Text color
                        fontSize: 16, // Text size
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text('Don\'t have an account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
