import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ConfirmDetailsScreen extends StatefulWidget {
  @override
  _ConfirmDetailsScreenState createState() => _ConfirmDetailsScreenState();
}

class _ConfirmDetailsScreenState extends State<ConfirmDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _spiceLevel = 'None';
  List<String> _dietaryRestrictions = [];
  String _cuisine = 'Option 1';
  File? _profileImage;

  final List<String> _spiceLevels = [
    'None', 
    'Mild', 
    'Medium', 
    'Hot', 
    'Very Hot'];
  final List<String> _dietaryOptions = [
    'Vegetarian', 
    'Vegan', 
    'Halal', 
    'Kosher', 
    'Gluten-free', 
    'Lactose intolerant', 
    'Diabetes', 
    'Low-sodium', 
    'Paleo', 
    'Cholesterol-restricted diet'];
  final List<String> _cuisineOptions = [
    'Mexican',
    'Italian',
    'Chinese',
    'Indian',
    'American'];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // Navigate to home page or handle signup
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _addDietaryRestriction(String restriction) {
    setState(() {
      if (!_dietaryRestrictions.contains(restriction)) {
        _dietaryRestrictions.add(restriction);
      }
    });
  }

  void _removeDietaryRestriction(String restriction) {
    setState(() {
      _dietaryRestrictions.remove(restriction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Darkmode.png',
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
                          'logo.png',
                          height: 80,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('default_profile.jpeg') as ImageProvider,
                        child: _profileImage == null
                            ? Icon(Icons.add, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 365,
                      height: 70,
                      child: TextFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Username:',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
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
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                        onChanged: (value) => _username = value,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 365,
                      height: 70,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Preferred spice level:',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
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
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        value: _spiceLevel,
                        items: _spiceLevels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _spiceLevel = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 365,
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Dietary restrictions:',
                                  labelStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
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
                                  ),
                                  filled: false,
                                  fillColor: Colors.transparent,
                                ),
                                items: _dietaryOptions.map((String option) {
                                  return DropdownMenuItem<String>(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  _addDietaryRestriction(newValue!);
                                },
                              ),
                            ),
                          ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(  
                      width: 365,
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _dietaryRestrictions
                        .map((restriction) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(  
                              restriction,
                              style: TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.red),
                              onPressed: () => _removeDietaryRestriction(restriction),
                            ),
                          ],
                        ))
                        .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 365,
                      height: 70,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Preferred cuisine:',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
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
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        value: _cuisine,
                        items: _cuisineOptions.map((String cuisine) {
                          return DropdownMenuItem<String>(
                            value: cuisine,
                            child: Text(cuisine),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _cuisine = newValue!;
                          });
                        },
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

