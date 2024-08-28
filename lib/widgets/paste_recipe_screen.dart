import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../gemini_service.dart'; 

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

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
  }

  Future<void> _processRecipe() async {
    // Ensure user ID is loaded
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ID is not available. Please login first.'),
        ),
      );
      return;
    }

    // Capture pasted text
    final pastedText = _recipeTextController.text;

    if (pastedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please paste a recipe before adding.'),
        ),
      );
      return;
    }

    // Call the Gemini service to extract the recipe data
    final extractedRecipeData = await extractRecipeData(pastedText);
    print("extracted data: $extractedRecipeData");

    if (extractedRecipeData != null && !extractedRecipeData.containsKey('error')) {
      // Add the extracted recipe data to the database using the _userId
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
                        color: Colors.grey), // Optional: customize the border color
                  ),
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                key: Key('recipe_button'),
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
