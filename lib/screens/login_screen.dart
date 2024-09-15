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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;
  String get _password => _passwordController.text;

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isMobile
                  ? (isLightTheme
                      ? 'assets/MobileLightMode.png'
                      : 'assets/MobileDarkMode.png')
                  : (isLightTheme
                      ? 'assets/Lightmode.png'
                      : 'assets/Darkermode.png'),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        cursorColor: textColor,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Email:',
                          labelStyle: TextStyle(fontSize: 20, color: textColor),
                          hintText: 'example@gmail.com',
                          hintStyle: const TextStyle(color: Color(0xFF778579)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFA9B8AC), width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFDC945F), width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 365,
                      height: 70,
                      child: TextFormField(
                        key: ValueKey('password'),
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        cursorColor: textColor,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Password:',
                          labelStyle: TextStyle(fontSize: 20, color: textColor),
                          hintText: '••••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF778579)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFA9B8AC), width: 2.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2954F), width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12.0),
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 365,
                      height: 46,
                      child: ElevatedButton(
                        key: ValueKey('Login'),
                        onPressed: _handleLogin,
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
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
