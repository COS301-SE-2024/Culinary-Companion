import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  final http.Client httpClient;
  final SharedPreferences sharedPreferences;

  SignupScreen({required this.httpClient, required this.sharedPreferences});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  // ignore: unused_field
  String _confirmPassword = '';

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final String edgeFunctionUrl =
          'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/hello-world';

      try {
        final response = await widget.httpClient.post(
          Uri.parse(edgeFunctionUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'action': 'signUp',
            'email': _email,
            'password': _password,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          //print('Sign up successful: ${responseBody['user']}');
          String userId = responseBody['user']['id'];

          await widget.sharedPreferences.setString('userId', userId);
          Navigator.pushReplacementNamed(context, '/confirm');
        } else {
          final responseBody = jsonDecode(response.body);
          //print('Sign up failed: ${responseBody['error']}');
          _showErrorDialog(responseBody['error']);
        }
      } catch (error) {
        //print('Error: $error');
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Sign Up'),
      // ),
      body: Stack(
        children: [
          //Background Image
          Positioned.fill(
            child: Image.asset(
              isLightTheme ? 'Lightmode.png' : 'Darkmode.png',
              fit: BoxFit.cover,
            ),
          ),
          //Foreground
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Logo and heading
                    Column(
                      children: [
                        Image.asset(
                          isLightTheme ? 'logo_1.png' : 'logo_2.png',
                          height: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 24,
                            color: isLightTheme
                                ? Color.fromARGB(255, 0, 0, 0)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                    Container(
                      width: 365,
                      height: 70,
                      child: TextFormField(
                        key: Key('emailField'),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Email:',
                          labelStyle: TextStyle(
                            fontSize: 20, // Increase the font size as needed
                            color: isLightTheme
                                ? Color.fromARGB(255, 94, 94, 94)
                                : Colors.white,
                          ),
                          hintText: 'example@gmail.com',
                          hintStyle: const TextStyle(color: Color(0xFF778579)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFA9B8AC),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFDC945F),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ), // Adjust padding to ensure label text sits above the border
                          filled: false,
                          fillColor: Colors.transparent,
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
                      const SizedBox(height: 16),
                      Container( 
                        width: 365,
                        height: 70,
                        child: TextFormField(
                          key: Key('passwordField'),
                          obscureText: true,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Password:',
                            labelStyle: TextStyle(
                              fontSize: 20,
                            color: isLightTheme
                                ? Color.fromARGB(255, 94, 94, 94)
                                : Colors.white,
                            ),
                            hintText: '••••••••••',
                            hintStyle: const TextStyle(color: Color(0xFF778579)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFA9B8AC), 
                                width: 2.0, 
                              ),                        
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFDC945F),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ), // Adjust padding to ensure label text sits above the border
                          filled: false,
                          fillColor: Colors.transparent,
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
                      const SizedBox(height: 16),
                      Container( 
                        width: 365,
                        height: 70,
                        child: TextFormField(
                          key: Key('confirmPasswordField'),
                          obscureText: true,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              fontSize: 20, 
                                                          color: isLightTheme
                                ? Color.fromARGB(255, 94, 94, 94)
                                : Colors.white,
                            ),
                            hintText: '••••••••••',
                            hintStyle: const TextStyle(color: Color(0xFF778579)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFA9B8AC),
                                width: 2.0,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2954F),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
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
                      const SizedBox(height: 24),
                      Container( 
                        width: 365,
                        height: 46,
                        child: ElevatedButton(
                          key: ValueKey('signupSubmitButton'),
                          onPressed: _handleSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC945F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            side: const BorderSide(
                              color: Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2954F),
                              width: 2.0,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 12.0,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: (value) => _confirmPassword = value,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 365,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC945F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          side: const BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
