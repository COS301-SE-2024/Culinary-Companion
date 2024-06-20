import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConfirmDetailsScreen extends StatefulWidget {
  @override
  _ConfirmDetailsScreenState createState() => _ConfirmDetailsScreenState();
}

class _ConfirmDetailsScreenState extends State<ConfirmDetailsScreen> {

  String? _userId;
  List<String>? _cuisineOptions;
  List<String>? _dietaryOptions;
  //bool _isLoading = true;
  //String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
   Future<void> _initializeData() async {
  try {
    await _loadUserId();
    final List<String> cuisineItems = await _loadCuisines();
    final List<String> constraintItems = await _loadDietaryConstraints();
    setState(() {
      _cuisineOptions = cuisineItems;
      _dietaryOptions = constraintItems;
     // _isLoading = false;
    });
  } catch (error) {
    print('Error initializing data: $error');
    setState(() {
      //_isLoading = false;
      //_errorMessage = 'Error initializing data';
    });
  }
}

Future<List<String>> _loadCuisines() async {
  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
  try {
    final response = await http.post(Uri.parse(url),
        body: json.encode({'action': 'getCuisines'}));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> cuisineItems =
          data.map<String>((cuisine) => cuisine['name'].toString()).toList();
      return cuisineItems;
    } else {
      throw Exception('Failed to load cuisines');
    }
  } catch (e) {
    throw Exception('Error fetching cuisines: $e');
  }
}


  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      print('Login successful: $_userId');
    });
  }
  Future<List<String>> _loadDietaryConstraints() async {
  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
  try {
    final response = await http.post(Uri.parse(url),
        body: json.encode({'action': 'getDietaryConstraints'}));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> constraintItems =
          data.map<String>((constraint) => constraint['name'].toString()).toList();
      return constraintItems;
    } else {
      throw Exception('Failed to load dietary constraints');
    }
  } catch (e) {
    throw Exception('Error fetching dietary constraints: $e');
  }
}

Future<void> _createUserProfile(String userId, String username, String cuisineName, int spiceLevel, String imageURL) async {
  final url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint'; // Replace with your actual backend endpoint
  // print('spice:  $spiceLevel');
  // print('userid:  $_userId');
  // print('name:  $username');
  // print('c:  $cuisineName');
  // print('image:  $imageURL');
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'createUserProfile',
        'userId': userId,
        'username': username,
        'cuisine': cuisineName,
        'spicelevel': spiceLevel,
        //'imageUrl': imageURL,
      }),
    );

    if (response.statusCode == 200) {
      print('User profile created successfully');
    } else {
      throw Exception('Failed to create user profile');
    }
  } catch (error) {
    print('Error creating user profile: $error');
  }
}


Future<void> _addUserDietaryConstraints(String userId, String dietaryConstraint) async {
  final url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint'; // Replace with your actual backend endpoint

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'addUserDietaryConstraints',
        'userId': userId,
        'dietaryConstraint': dietaryConstraint,
      }),
    );

    if (response.statusCode == 200) {
      print('Dietary constraint added successfully');
    } else {
      throw Exception('Failed to add dietary constraint');
    }
  } catch (error) {
    print('Error adding dietary constraint: $error');
  }
}

int getSpiceLevelNumber(String spiceLevel) {
    switch (spiceLevel) {
      case 'None':
        return 1;
      case 'Mild🌶️':
        return 2;
      case 'Medium🌶️🌶️':
        return 3;
      case 'Hot🌶️🌶️🌶️':
        return 4;
      case 'Extra Hot🌶️🌶️🌶️🌶️':
        return 5;
      default:
        throw Exception('Invalid spice level');
    }
  }
  
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  String _username = '';
  String _spiceLevel = 'None';
  List<String> _dietaryRestrictions = [];
  String _cuisine = 'Mexican';
  File? _profileImage;

  final List<String> _spiceLevels = [
    'None', 
    'Mild🌶️', 
    'Medium🌶️🌶️', 
    'Hot🌶️🌶️🌶️', 
    'Extra Hot🌶️🌶️🌶️🌶️'];

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
      int spiceLevel = getSpiceLevelNumber(_spiceLevel);
      
      _createUserProfile(_userId!, _username, _cuisine, spiceLevel, _profileImage != null ? _profileImage!.path : ''); // Call to create user profile
      for (String restriction in _dietaryRestrictions) {
      _addUserDietaryConstraints(_userId!, restriction); // Call to add dietary constraints
    }
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
                    // GestureDetector(
                    //   onTap: _pickImage,
                    //   child: CircleAvatar(
                    //     radius: 50,
                    //     backgroundImage: _profileImage != null
                    //         ? FileImage(_profileImage!)
                    //         : const AssetImage('default_profile.jpeg') as ImageProvider,
                    //     child: _profileImage == null
                    //         ? const Icon(Icons.add, size: 50, color: Color(0xFFDC945F))
                    //         : null,
                    //   ),
                    // ),
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
                        dropdownColor: const Color(0xFF1F4539),
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
                    const SizedBox(height: 2),
                    Container(
                      width: 365,
                      height: 70,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: const Color(0xFF1F4539),
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
                              items: _dietaryOptions?.map((String option) {
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
                              style: const TextStyle(
                                fontSize: 16, 
                                color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.red),
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
                        dropdownColor: const Color(0xFF1F4539),
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
                        items: _cuisineOptions?.map((String cuisine) {
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
                    // TextButton(
                    //   onPressed: () {
                    //     Navigator.pushNamed(context, '/login');
                    //   },
                    //   child: const Text('Already have an account? Login'),
                    // ),r
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

