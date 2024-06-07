import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _profileImage;
  String? _userId;
  List<DropdownMenuItem<String>>? _cuisines;
  List<DropdownMenuItem<String>>? _dietaryConstraints;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userDetails;
  String? _selectedCuisine; // 1. Added variable

  @override

  void initState() {
  super.initState();
  _initializeData();
}

Future<void> _initializeData() async {
  await _loadUserId();
  await  _fetchUserDetails(); // Fetch user details on init
    _loadCuisines().then((cuisineItems) {
      setState(() {
        _cuisines = cuisineItems;
        print('Fetched cuisines');
      });
    }).catchError((error) {
      print('Error loading cuisines: $error');
    });

    _loadDietaryConstraints().then((constraintsItems) {
      setState(() {
        _dietaryConstraints = constraintsItems;
        print('Fetched dietary constraints');
      });
    }).catchError((error) {
      print('Error loading dietary constraints: $error');
    });
  }

  // Load user ID
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      print('Login successful: $_userId');
    });
  }

  ///////////fetch the users profile details/////////
  Future<void> _fetchUserDetails() async {
  if (_userId == null) return;

  final String url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'getUserDetails',
        'userId': _userId,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Response data: $data'); //response data
      if (data.isNotEmpty) {
        setState(() {
          _userDetails = data[0]; //get the first item in the list
          _isLoading = false;
          _selectedCuisine =
              _userDetails?['cuisine']?.toString() ?? 'Mexican';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user details found';
        });
      }
    } else {
      // Handle error
      print('Failed to load user details: ${response.statusCode}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user details';
      });
    }
  } catch (error) {
    //error handlind
    print('Error fetching user details: $error');
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error fetching user details';
    });
  }
}

  // Load list of cuisines
  Future<List<DropdownMenuItem<String>>> _loadCuisines() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({'action': 'getCuisines'}));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<DropdownMenuItem<String>> cuisineItems =
            data.map<DropdownMenuItem<String>>((cuisine) {
          return DropdownMenuItem<String>(
            value: cuisine['name'].toString(),
            child: Text(
              cuisine['name'].toString(),
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList();
        return cuisineItems;
      } else {
        throw Exception('Failed to load cuisines');
      }
    } catch (e) {
      throw Exception('Error fetching cuisines: $e');
    }
  }

  // Load dietary restraints
  Future<List<DropdownMenuItem<String>>> _loadDietaryConstraints() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({'action': 'getDietaryConstraints'}));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<DropdownMenuItem<String>> constraintItems =
            data.map<DropdownMenuItem<String>>((constraint) {
          return DropdownMenuItem<String>(
            value: constraint['name'].toString(),
            child: Text(
              constraint['name'].toString(),
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList();

        // If the response is empty, add a default item
        if (constraintItems.isEmpty) {
          constraintItems.add(
            DropdownMenuItem<String>(
              value: 'No dietary constraints',
              child: Text(
                'No dietary constraints',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return constraintItems;
      } else {
        throw Exception('Failed to load dietary constraints');
      }
    } catch (e) {
      throw Exception('Error fetching dietary constraints: $e');
    }
  }

  // Update user cuisine
  Future<void> updateUserCuisine(String userId, String cuisine) async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'action': 'updateUserCuisine',
          'userId': userId,
          'cuisine': cuisine,
        }),
      );

      if (response.statusCode == 200) {
        print('Cuisine updated successfully');
      } else {
        throw Exception('Failed to update cuisine');
      }
    } catch (e) {
      print('Error updating cuisine: $e');
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @
  override
  Widget build(BuildContext context) {
    //final String? preferredCuisine = _userDetails?['cuisine']?.toString() ?? 'Mexican';//default
    print('User\'s preferred cuisine: $_selectedCuisine');
    return Scaffold(
      backgroundColor: const Color(0xFF20493C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20493C),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : AssetImage('assets/profile.jpeg')
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Name',
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: 'Jane Doe',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Email',
                  style: TextStyle(color: Colors.white),
                ),
                TextFormField(
                  initialValue: 'jane.doe@gmail.com',
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Spice Level',
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButton<String>(
                  value: 'Mild',
                  dropdownColor: const Color(0xFF20493C),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                  items: <String>['Mild', 'Medium', 'Hot', 'Extra Hot']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'Preferred Cuisine',
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButton<String>(
                  value: _selectedCuisine,
                  dropdownColor: const Color(0xFF20493C),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCuisine = newValue!;
                    });
                    updateUserCuisine(_userId!, newValue!); // Call the function to update cuisine
                  },
                  items: _cuisines?.map((DropdownMenuItem<String> item) {
                    return item;
                  }).toList(),
                ),

                SizedBox(height: 16),
                Text(
                  'Dietary Constraints',
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButton<String>(
                  value: 'Vegan',
                  dropdownColor: const Color(0xFF20493C),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                  items: _dietaryConstraints?.map((DropdownMenuItem<String> item) {
                    return item;
                  }).toList(),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle save action
                      },
                      child: Text('Save'),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(
                            context); // Navigate back to previous screen
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
