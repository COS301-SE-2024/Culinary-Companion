import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanRecipe extends StatefulWidget {
  @override
  _ScanRecipeState createState() => _ScanRecipeState();
}

class _ScanRecipeState extends State<ScanRecipe> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        _image = pickedImage;
      });
    }
    if (_image != null) {
      // Handle the picked image as needed
      print('Image picked: ${_image!.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 100),
          const Text(
            'Drag & Drop Recipe Here',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth *
                    0.1, // Adjust the horizontal padding based on screen width
                vertical: 20,
              ),
            ),
            child: Text(
              'Browse Files',
              style: TextStyle(color: textColor),
            ),
          ),
          const SizedBox(height: 150),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                key: Key('recipe_button'),
                onPressed: () {
                  // Add functionality to format the scanned recipe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth *
                        0.09, // Adjust the horizontal padding based on screen width
                    vertical: 20, // Adjust the vertical padding based on screen width
                  ),
                ),
                child: Text(
                  'Format Recipe',
                  style: TextStyle(
                    color: Colors.white,
                    // fontSize: screenWidth *
                    //     0.045, // Adjust the font size based on screen width
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to analyze the scanned recipe
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth *
                          0.09, // Adjust the horizontal padding based on screen width
                      vertical: 20, // Adjust the vertical padding based on screen width
                    ),
                    side: const BorderSide(color: Color(0xFFDC945F), width: 2),
                    elevation: 0),
                child: Text(
                  'Analyze Recipe',
                  style: TextStyle(
                    color: const Color(0xFFDC945F),
                    // fontSize: screenWidth *
                    //     0.045, // Adjust the font size based on screen width
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
