import 'package:flutter/material.dart';

class PastRecipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                //key: Key('recipe_button'),
                onPressed: () {
                  // Add functionality to format the pasted recipe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFDC945F), // Set the background color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text(
                  'Format Recipe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                //key: Key('recipe_button'),
                onPressed: () {
                  // Add functionality to analyze the pasted recipe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : Color(0xFF1F4539), // Set the background color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  side: const BorderSide(color: Color(0xFFDC945F), width: 2),
                ),
                child: const Text(
                  'Analyze Recipe',
                  style: TextStyle(
                    color: Color(0xFFDC945F),
                    fontSize: 18,
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
