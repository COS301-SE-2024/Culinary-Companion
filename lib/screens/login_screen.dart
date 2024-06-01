import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  final String edgeFunctionUrl = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/hello-world';

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
      body: jsonEncode({'action': action, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // Authentication successful, handle the user object as needed
      print('Login successful: ${responseBody['user']}');
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
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onChanged: (value) => _email = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) => _password = value,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login'),
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
    );
  }
}
