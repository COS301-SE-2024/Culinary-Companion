import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _profileImage;
  String? _userId;
  List<DropdownMenuItem<String>>? _cuisines;
  List<MultiSelectItem<String>>? _dietaryConstraints;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userDetails;
  String? _selectedCuisine;
  String? _username;
  List<String> _selectedDietaryConstraints = [];
  String? _spiceLevel;
  String? _profilePhoto;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserId();
      await _fetchUserDetails(); // Fetch user details on init
      final List<DropdownMenuItem<String>> cuisineItems = await _loadCuisines();
      final List<MultiSelectItem<String>> constraintItems =
          await _loadDietaryConstraints();

      setState(() {
        _cuisines = cuisineItems;
        _dietaryConstraints = constraintItems;
        _isLoading = false;
      });
    } catch (error) {
      print('Error initializing data: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing data';
      });
    }
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      print('Login successful: $_userId');
    });
  }

  Future<void> _fetchUserDetails() async {
    if (_userId == null) return;

    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
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
            _username = _userDetails?['username']?.toString() ?? 'Jane Doe';
            _spiceLevel =
                _userDetails?['spicelevel']?.toString() ?? 'Mild'; //default
            _selectedDietaryConstraints = List<String>.from(
                _userDetails?['dietaryConstraints']
                        ?.map((dc) => dc.toString()) ??
                    []);
            _profilePhoto =
                _userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';
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
      //error handling
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
  Future<List<MultiSelectItem<String>>> _loadDietaryConstraints() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({'action': 'getDietaryConstraints'}));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<MultiSelectItem<String>> constraintItems =
            data.map<MultiSelectItem<String>>((constraint) {
          return MultiSelectItem<String>(
            constraint['name'].toString(),
            constraint['name'].toString(),
          );
        }).toList();
        return constraintItems;
      } else {
        throw Exception('Failed to load dietary constraints');
      }
    } catch (e) {
      throw Exception('Error fetching dietary constraints: $e');
    }
  }

  Future<void> addUserDietaryConstraint(
      String userId, String constraint) async {
    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'addUserDietaryConstraints',
          'userId': userId,
          'dietaryConstraint': constraint,
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

  Future<void> removeUserDietaryConstraint(
      String userId, String constraint) async {
    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'removeUserDietaryConstraints',
          'userId': userId,
          'dietaryConstraint': constraint,
        }),
      );

      if (response.statusCode == 200) {
        print('Dietary constraint removed successfully');
      } else {
        throw Exception('Failed to remove dietary constraint');
      }
    } catch (error) {
      print('Error removing dietary constraint: $error');
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

  Future<void> updateUserUsername(String userId, String username) async {
    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'updateUserUsername',
          'userId': userId,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        print('Username updated successfully');
      } else {
        throw Exception('Failed to update username');
      }
    } catch (error) {
      print('Error updating username: $error');
    }
  }

  Future<void> _saveProfileChanges() async {
    try {
      await updateUserUsername(_userId!, _username!);

      // Update cuisine
      await updateUserCuisine(_userId!, _selectedCuisine!);

      // Remove unticked dietary constraints
      for (String constraint in _userDetails?['dietaryConstraints'] ?? []) {
        if (!_selectedDietaryConstraints.contains(constraint)) {
          await removeUserDietaryConstraint(_userId!, constraint);
        }
      }

      // Add new dietary constraints
      for (String constraint in _selectedDietaryConstraints) {
        if (!(_userDetails?['dietaryConstraints']?.contains(constraint) ??
            false)) {
          await addUserDietaryConstraint(_userId!, constraint);
        }
      }

      print('Profile updated successfully');
      // You can navigate to another screen or show a success message here
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                //_profileImage != null,
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : _profilePhoto != null &&
                              _profilePhoto!.startsWith('http')
                          ? NetworkImage(_profilePhoto!)
                          : AssetImage(_profilePhoto ??
                              'assets/default_profile_photo.jpg'),
                ),

                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  )
                else
                  Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: TextEditingController(text: _username),
                        onSubmitted: (newValue) {
                          setState(() {
                            _username = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedCuisine,
                        items: _cuisines,
                        onChanged: (value) {
                          setState(() {
                            _selectedCuisine = value;
                            //updateUserCuisine(_userId!, value!);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Preferred Cuisine',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                        ),
                        dropdownColor: Color(0xFF20493C),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      MultiSelectDialogField<String>(
                        items: _dietaryConstraints!,
                        initialValue: _selectedDietaryConstraints,
                        title: Text("Dietary Constraints"),
                        selectedColor: Colors.blue,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        buttonIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blue,
                        ),
                        buttonText: Text(
                          "Select Dietary Constraints",
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 16,
                          ),
                        ),
                        onConfirm: (results) {
                          setState(() {
                            _selectedDietaryConstraints = results;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _spiceLevel = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Spice Level',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                        ),
                        style: TextStyle(color: Colors.white),
                        controller: TextEditingController(text: _spiceLevel),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProfileChanges,
                        child: Text('Save Changes'),
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
