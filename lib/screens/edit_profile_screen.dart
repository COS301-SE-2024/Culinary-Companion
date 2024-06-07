import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/navbar.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            : AssetImage('assets/profile.jpeg') as ImageProvider,
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
                  value: 'Mexican',
                  dropdownColor: const Color(0xFF20493C),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                  items: <String>['Mexican', 'Italian', 'Chinese', 'Indian']
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
                  'Dietary Constraints',
                  style: TextStyle(color: Colors.white),
                ),
                DropdownButton<String>(
                  value: 'None',
                  dropdownColor: const Color(0xFF20493C),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                  items: <String>['None', 'Dairy', 'Vegan']
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
                        Navigator.pop(context); // Navigate back to previous screen
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
