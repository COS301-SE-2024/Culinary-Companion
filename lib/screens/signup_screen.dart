import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final String edgeFunctionUrl = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/hello-world';
      
      try {
        final response = await http.post(
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
          // Authentication successful, handle the user object as needed
          print('Sign up successful: ${responseBody['user']}');
          String userId = responseBody['user']['id'];
        
          // Save the userId to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          final responseBody = jsonDecode(response.body);
          // Authentication failed, handle the error
          print('Sign up failed: ${responseBody['error']}');
          _showErrorDialog(responseBody['error']);
        }
      } catch (error) {
        print('Error: $error');
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
              SizedBox(height: 16),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSignup,
                child: Text('Sign Up'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
