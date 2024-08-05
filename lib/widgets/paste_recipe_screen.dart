import 'package:flutter/material.dart';

class PasteRecipe extends StatelessWidget {
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
                        color: Colors
                            .grey), // Optional: customize the border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors
                            .transparent), // Optional: customize the border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors
                            .transparent), // Optional: customize the border color on focus
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
                onPressed: () {
                  // Add functionality to format the scanned recipe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC945F),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth *
                        0.08, // Adjust the horizontal padding based on screen width
                    vertical: screenWidth *
                        0.04, // Adjust the vertical padding based on screen width
                  ),
                ),
                child: Text(
                  'Format Recipe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth *
                        0.045, // Adjust the font size based on screen width
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
                          0.08, // Adjust the horizontal padding based on screen width
                      vertical: screenWidth *
                          0.04, // Adjust the vertical padding based on screen width
                    ),
                    side: const BorderSide(color: Color(0xFFDC945F), width: 2),
                    elevation: 0),
                child: Text(
                  'Analyze Recipe',
                  style: TextStyle(
                    color: const Color(0xFFDC945F),
                    fontSize: screenWidth *
                        0.045, // Adjust the font size based on screen width
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
