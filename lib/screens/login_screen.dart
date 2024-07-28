import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class LoginScreen extends StatefulWidget {
  final http.Client client;

  LoginScreen({Key? key, http.Client? client})
      : client = client ?? http.Client(),
        super(key: key);

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
      loginUser(_email, _password, 'signIn');
    }
  }

Future<void> loginUser(String email, String password, String action) async {
  try {
    final response = await widget.client.post(
      Uri.parse(edgeFunctionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String userId = responseBody['user']['id'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final responseBody = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${responseBody['error']}')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $error')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;
    final FocusNode passwordFocusNode = FocusNode();

    return Scaffold(
      body: Stack(
        children: [
          //Background image
          Positioned.fill(
            child: Image.asset(
              isLightTheme ? 'assets/Lightmode.png' : 'assets/Darkmode.png',
              fit: BoxFit.cover,
            ),
          ),
          //Foreground content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Logo and welcome text
                    Column(
                      children: [
                        Image.asset(
                          isLightTheme
                              ? 'assets/logo_1.png'
                              : 'assets/logo_2.png',
                          height: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                        key: ValueKey('email'),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Email:',
                          labelStyle: TextStyle(
                            fontSize: 20,
                            color: textColor,
                          ),
                          hintText: 'example@gmail.com',
                          hintStyle: const TextStyle(color: Color(0xFF778579)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Adjust the border radius as needed
                            borderSide: const BorderSide(
                              color: Color(0xFFA9B8AC), // Set the border color
                              width:
                                  2.0, // Adjust the border thickness as needed
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Ensure the border radius matches
                            borderSide: const BorderSide(
                              color: Color(
                                  0xFFDC945F), // Set the border color when the field is focused
                              width:
                                  2.0, // Adjust the border thickness as needed
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
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
                    const SizedBox(height: 16),
                    // Container(
                    //   width: 365,
                    //   height: 70,
                    //   child: TextFormField(
                    //     key: ValueKey('password'),
                    //     obscureText: true,
                    //     decoration: InputDecoration(
                    //       floatingLabelBehavior: FloatingLabelBehavior.always,
                    //       labelText: 'Password:',
                    //       labelStyle: TextStyle(fontSize: 20, color: textColor),
                    //       hintText: '••••••••••',
                    //       hintStyle: const TextStyle(color: Color(0xFF778579)),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(
                    //             8.0), // Adjust the border radius as needed
                    //         borderSide: const BorderSide(
                    //           color: Color(0xFFA9B8AC), // Set the border color
                    //           width:
                    //               2.0, // Adjust the border thickness as needed
                    //         ),
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(
                    //             8.0), // Ensure the border radius matches
                    //         borderSide: const BorderSide(
                    //           color: Color(
                    //               0xFFE2954F), // Set the border color when the field is focused
                    //           width:
                    //               2.0, // Adjust the border thickness as needed
                    //         ),
                    //       ),
                    //       contentPadding: const EdgeInsets.symmetric(
                    //         vertical: 12.0,
                    //         horizontal: 12.0,
                    //       ), // Adjust padding to ensure label text sits above the border
                    //       filled: false, // Ensure the filled property is false
                    //       fillColor: Colors
                    //           .transparent, // Set fillColor to transparent if needed
                    //     ),
                    //     validator: (value) {
                    //       if (value == null || value.isEmpty) {
                    //         return 'Please enter your password';
                    //       }
                    //       return null;
                    //     },
                    //     onChanged: (value) => _password = value,
                    //   ),
                    // ),
                    Container(
                      width: 365,
                      height: 70,
                      child: TextFormField(
                        key: ValueKey('password'),
                        obscureText: true,
                        focusNode: passwordFocusNode,
                        onFieldSubmitted: (value) => _handleLogin(),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Password:',
                          labelStyle: TextStyle(fontSize: 20, color: textColor),
                          hintText: '••••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF778579)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Adjust the border radius as needed
                            borderSide: const BorderSide(
                              color: Color(0xFFA9B8AC), // Set the border color
                              width:
                                  2.0, // Adjust the border thickness as needed
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Ensure the border radius matches
                            borderSide: const BorderSide(
                              color: Color(
                                  0xFFE2954F), // Set the border color when the field is focused
                              width:
                                  2.0, // Adjust the border thickness as needed
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
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
                    // SizedBox(height: 4),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       //Handle forgot password
                    //     },
                    //     child: Text(
                    //       'Forgot password?',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),
                    Container(
                      width: 365,
                      height: 46,
                      child: ElevatedButton(
                        key: ValueKey('Login'),
                        onPressed: _handleLogin,
                        focusNode: passwordFocusNode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFFDC945F), // Button background color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Border radius
                          ),
                          side: const BorderSide(
                            color: Colors.transparent, // Border color
                            width: 2.0, // Border thickness
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16, // Text size
                          ),
                        ),
                      ),
                    ),
                    // Container(
                    //   width: 365,
                    //   height: 46,
                    //   child: ElevatedButton(
                    //     key: ValueKey('Login'),
                    //     onPressed: _handleLogin,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(
                    //           0xFFDC945F), // Button background color
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius:
                    //             BorderRadius.circular(8.0), // Border radius
                    //       ),
                    //       side: const BorderSide(
                    //         color: Colors.transparent, // Border color
                    //         width: 2.0, // Border thickness
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Login',
                    //       style: TextStyle(
                    //         color: Colors.white, // Text color
                    //         fontSize: 16, // Text size
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    //Line with "or" text
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Container(
                    //       width: 160,
                    //       height: 1,
                    //       color: Colors.white,
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 10),
                    //       child: Text(
                    //         'or',
                    //         style: TextStyle(color: Colors.white, fontSize: 18),
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 160,
                    //       height: 1,
                    //       color: Colors.white,
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 16),
                    // Container(
                    //   width: 365,
                    //   height: 46,
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {
                    //       // Handle Google login
                    //     },
                    //     icon: Image.asset(
                    //       'google.png',
                    //       height: 24,
                    //     ),
                    //     label: const Text(
                    //       'Log in with Google',
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8.0),
                    //       ),
                    //       side: const BorderSide(
                    //         color: Colors.transparent,
                    //         width: 2.0,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: ValueKey('signupLink'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
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
