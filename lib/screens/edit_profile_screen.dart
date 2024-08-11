import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart'; // Step 1: Import Lottie package

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String? _userId;
  List<DropdownMenuItem<String>>? _cuisines;
  List<MultiSelectItem<String>>? _dietaryConstraints;
  bool _isLoading = true;
  // String? _errorMessage;
  Map<String, dynamic>? _userDetails;
  String? _selectedCuisine;
  String? _username;
  List<String> _selectedDietaryConstraints = [];
  String? _spiceLevel;
  //SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  String imageUrl = "";
  //final void Function(String imageUrl) onUpload;
  // Pick image from gallery

  Future<void> _pickImage() async {
    //print('Starting image picking process...');

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('No image selected.');
      return;
    }

    //print('Image picked: ${image.path}');
    //print('User ID: $_userId');
    final supabase = Supabase.instance.client;
    //final userId = _userId;//await supabase.auth.currentUser!.id;
    //final user = supabase.auth.currentUser;

    //final imageEx = image.path.split('.').last.toLowerCase();
    final imagePath = '/$_userId/profile_photos';
    //print('Image extension: $imageEx');
    //print('Image path: $imagePath');

    final imageBytes = await image.readAsBytes();
    //print('image bytes:$imageBytes');

    //print('Uploading image to Supabase storage...');
    try {
      final response =
          await supabase.storage.from('profile_photos').uploadBinary(
                '/$_userId/profile_photos',
                imageBytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: 'image/*',
                ),
              );
      //print("here");

      if (response.isNotEmpty) {
        //('Image uploaded successfully.');

        imageUrl =
            supabase.storage.from('profile_photos').getPublicUrl(imagePath);

        //print('Image URL: $imageUrl');

        imageUrl = Uri.parse(imageUrl).replace(queryParameters: {
          't': DateTime.now().microsecondsSinceEpoch.toString()
        }).toString();

        //print('Updated image URL: $imageUrl');

        await supabase
            .from('userProfile')
            .update({'profilephoto': imageUrl}).eq('userid', _userId!);
        if (mounted) {
          setState(() {
            imageUrl = imageUrl;
          });
        }
        //print('User profile photo updated successfully.');
      } else {
        print('Error uploading image: $response');
      }
    } catch (error) {
      print('Exception during image upload: $error');
    }
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserId();
      await _fetchUserDetails(); // Fetch user details on init
      final List<DropdownMenuItem<String>> cuisineItems = await _loadCuisines();
      final List<MultiSelectItem<String>> constraintItems =
          await _loadDietaryConstraints();
if (mounted) {
      setState(() {
        _cuisines = cuisineItems;
        _dietaryConstraints = constraintItems;
        //_isLoading = false;
      });}
    } catch (error) {
      print('Error initializing data: $error');
      if (mounted) {
      setState(() {
        //_isLoading = false;
        //_errorMessage = 'Error initializing data';
      });}
    }
    _isLoading = false;
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
    setState(() {
      _userId = prefs.getString('userId');
      //print('Login successful: $_userId');
    });}
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
        //print('Response data: $data'); //response data
        if (data.isNotEmpty) {
          if (mounted) {
          setState(() {
            _userDetails = data[0]; //get the first item in the list

            _selectedCuisine =
                _userDetails?['cuisine']?.toString() ?? 'Mexican';
            _username = _userDetails?['username']?.toString() ?? 'Jane Doe';
            _spiceLevel =
                _userDetails?['spicelevel']?.toString() ?? 'Mild'; //default
            _spiceLevel = getSpiceLevelText(_spiceLevel);

            _selectedDietaryConstraints = List<String>.from(
                _userDetails?['dietaryConstraints']
                        ?.map((dc) => dc.toString()) ??
                    []);
            imageUrl =
                _userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';

            //_profilePhoto =_userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';
            //_isLoading = false;
          });}
        } else {
          if (mounted) {
          setState(() {
            _isLoading = false;
            //_errorMessage = 'No user details found';
          });}
        }
      } else {
        // Handle error
        print('Failed to load user details: ${response.statusCode}');
        if (mounted) {
        setState(() {
          _isLoading = false;
          // _errorMessage = 'Failed to load user details';
        });}
      }
    } catch (error) {
      //error handling
      print('Error fetching user details: $error');
      if (mounted) {
      setState(() {
        _isLoading = false;
        //_errorMessage = 'Error fetching user details';
      });}
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

  // For profile photo
  Widget _buildProfilePhoto() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : AssetImage('assets/pfp.jpg') as ImageProvider,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDC945F),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // For username
  Widget _buildUsername() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Username:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            cursorColor: textColor,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0B3D36)),
                borderRadius: BorderRadius.circular(10),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: TextStyle(color: Colors.white, fontSize: 16),
            controller: TextEditingController(text: _username),
            onSubmitted: (newValue) {
              if (mounted) {
              setState(() {
                _username = newValue;
              });}
            },
          ),
        ],
      ),
    );
  }

  // For cuisine drop down
  Widget _buildCuisineDropdown() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred Cuisine:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            dropdownColor: Color(0xFF20493C),
            value: _selectedCuisine,
            items: _cuisines,
            onChanged: (value) {
              if (mounted) {
              setState(() {
                _selectedCuisine = value;
                //updateUserCuisine(_userId!, value!);
              });}
            },
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0B3D36)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // For spice level radio buttons
  Widget _buildSpiceLevelRadio() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 830;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferred Spice Level:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              isSmallScreen
                  ? Column(
                      children: ['None', 'Mild', 'Medium', 'Hot', 'Very Hot']
                          .map((level) {
                        return RadioListTile<String>(
                          title: Text(level),
                          value: level,
                          groupValue: _spiceLevel,
                          onChanged: (value) {
                            if(mounted){
                            setState(() {
                              _spiceLevel = value;
                            });}
                          },
                        );
                      }).toList(),
                    )
                  : Row(
                      children: ['None', 'Mild', 'Medium', 'Hot', 'Very Hot']
                          .map((level) {
                        return Expanded(
                          child: RadioListTile<String>(
                            title: Text(level),
                            value: level,
                            groupValue: _spiceLevel,
                            onChanged: (value) {
                              if (mounted) {
                              setState(() {
                                _spiceLevel = value;
                              });}
                            },
                          ),
                        );
                      }).toList(),
                    ),
            ],
          );
        },
      ),
    );
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
        //print('Dietary constraint added successfully');
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
        //print('Dietary constraint removed successfully');
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
        //print('Cuisine updated successfully');
      } else {
        throw Exception('Failed to update cuisine');
      }
    } catch (e) {
      print('Error updating cuisine: $e');
    }
  }

  Future<void> updateUserSpiceLevel(String userId, int spiceLevel) async {
    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'updateUserSpiceLevel',
          'userId': userId,
          'spicelevel': spiceLevel,
        }),
      );

      if (response.statusCode == 200) {
        //print('Spice level updated successfully');
      } else {
        throw Exception('Failed to update spice level');
      }
    } catch (error) {
      print('Error updating spice level: $error');
    }
  }

  String getSpiceLevelText(String? spiceLevel) {
    switch (spiceLevel) {
      case '1':
        return 'None';
      case '2':
        return 'Mild';
      case '3':
        return 'Medium';
      case '4':
        return 'Hot';
      case '5':
        return 'Extra Hot';
      default:
        return 'Unknown';
    }
  }

  int getSpiceLevelNumber(String spiceLevel) {
    switch (spiceLevel) {
      case 'None':
        return 1;
      case 'Mild':
        return 2;
      case 'Medium':
        return 3;
      case 'Hot':
        return 4;
      case 'Extra Hot':
        return 5;
      default:
        throw Exception('Invalid spice level');
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
        //print('Username updated successfully');
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

      // Update spice level
      await updateUserSpiceLevel(_userId!, getSpiceLevelNumber(_spiceLevel!));

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

      //print('Profile updated successfully');
      Navigator.pop(context, true);

      // You can navigate to another screen or show a success message here
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  // For dietary constraints multi-select
  Widget _buildDietaryConstraintsMultiSelect() {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Constraints',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          MultiSelectDialogField<String>(
            checkColor: Colors.white,
            selectedColor: Color(0xFF20493C),
            backgroundColor: Color(0xFFDC945F),
            items: _dietaryConstraints!,
            initialValue: _selectedDietaryConstraints,
            onConfirm: (values) {
              if (mounted) {
              setState(() {
                _selectedDietaryConstraints = values;
              });}
            },
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Color(0xFFDC945F),
              textStyle: TextStyle(color: Color(0xFF20493C), fontSize: 16),
            ),
            buttonText: Text(
              'Select Dietary Constraints',
              style: TextStyle(
                color: textColor,
              ),
            ),
            buttonIcon: Icon(
              Icons.arrow_drop_down,
              color: textColor,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                color:
                    textColor, // Change this color to the desired border color
                width: 1, // Change the width as needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final String profilePhoto =
    //     _userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';
    // print('User\'s preferred cuisine: $_selectedCuisine');
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: TextStyle(color: textColor)),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Lottie.asset('assets/loading.json'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePhoto(),
            const SizedBox(height: 20),
            _buildUsername(),
            const SizedBox(height: 20),
            _buildCuisineDropdown(),
            const SizedBox(height: 20),
            _buildSpiceLevelRadio(),
            const SizedBox(height: 20),
            _buildDietaryConstraintsMultiSelect(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfileChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
