import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../gemini_service.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasteRecipe extends StatefulWidget {
  @override
  _PasteRecipeState createState() => _PasteRecipeState();
}

class _PasteRecipeState extends State<PasteRecipe> {
  String? _userId;
  final TextEditingController _recipeTextController = TextEditingController(); // Controller for capturing pasted text

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  String _imageUrl = "";
  String? _selectedImage;

final List<String> _preloadedImages = [
  'https://gsnhwvqprmdticzglwdf.supabase.co/storage/v1/object/public/recipe_photos/default.jpg?t=2024-07-23T07%3A29%3A02.690Z'
];

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
  }

   Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('No image selected.');
      return;
    }

    final supabase = Supabase.instance.client;
    final imageBytes = await image.readAsBytes();
    final imageName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final imagePath = 'recipe_photos/$imageName';

    try {
      final response = await supabase.storage.from('recipe_photos').uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/*',
            ),
          );

      if (response.isNotEmpty) {
        _imageUrl =
            supabase.storage.from('recipe_photos').getPublicUrl(imagePath);
        if (mounted) {
          setState(() {
            _selectedImage = _imageUrl;
          });
        }
      } else {
        print('Error uploading image: $response');
      }
    } catch (error) {
      print('Exception during image upload: $error');
    }
  }

  Future<void> _processRecipe() async {
  if (_userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User ID is not available. Please login first.'),
      ),
    );
    return;
  }

  final pastedText = _recipeTextController.text;

  if (pastedText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please paste a recipe before adding.'),
      ),
    );
    return;
  }

  // send pasted text and image url 
  final extractedRecipeData = await extractRecipeData(
    pastedText,
    _selectedImage ?? _preloadedImages[0],
  );

  if (extractedRecipeData != null && !extractedRecipeData.containsKey('error')) {
    await addExtractedRecipeToDatabase(extractedRecipeData, _userId!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe added successfully!'),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to extract recipe data.'),
      ),
    );
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
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 32.0),
            child: Row(
              children: [
                Text(
                  'Paste Recipe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                controller: _recipeTextController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.top,
                cursorColor: textColor,
                decoration: InputDecoration(
                  hintText: 'Paste your recipe here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isLightTheme ? Colors.white : Color(0xFF1F4539),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text(
              'Upload Image',
              style: TextStyle(color: textColor),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Or use the preloaded image:'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: _preloadedImages.map((image) {
              return GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _selectedImage = image;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedImage == image
                          ? Colors.blue
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Image.network(
                    image,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _processRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.09,
                    vertical: 20,
                  ),
                ),
                child: Text(
                  'Add Recipe',
                  style: TextStyle(
                    color: Colors.white,
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