import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../gemini_service.dart'; // LLM
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class GuestCheckableItem extends StatefulWidget {
  final String title;
  final double requiredQuantity;
  final String requiredUnit;
  final ValueChanged<bool?> onChanged;
  final String recipeID;
  final Function(Map<String, dynamic>) onRecipeUpdate;

  GuestCheckableItem({
    required this.title,
    required this.requiredQuantity,
    required this.requiredUnit,
    required this.onChanged,
    required this.recipeID,
    required this.onRecipeUpdate,
  });

  @override
  _CheckableItemState createState() => _CheckableItemState();
}

class _CheckableItemState extends State<GuestCheckableItem> {

  void _showSubstitutesDialog() async {
    //loading screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Loading substitutions...',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Replace CircularProgressIndicator with your custom loading animation
              Lottie.asset(
                'assets/loading.json', // Path to your Lottie file
                // width: 100,
                // height: 100,
                // fit: BoxFit.fill,
              ),
            ],
          ),
          backgroundColor: Colors.white, // Set background color to white
        );
      },
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    //fetch substitutions
    String jsonString = await fetchIngredientSubstitutions(widget.recipeID,
        widget.title, userId ?? 'defaultUserId'); // add user id

    // Parse the JSON string
    Map<String, dynamic> substitutions;
    try {
      substitutions = jsonDecode(jsonString);
    } catch (e) {
      Navigator.of(context).pop(); //stop loading screen
      // Show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(color: Colors.black),
            ),
            content: Text(
              'Failed to fetch substitutions.',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFFDC945F),
                    width: 1.5,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFFDC945F),
                  ), // Set text color to black
                ),
              ),
            ],
            backgroundColor: Colors.white, // Set background color to white
          );
        },
      );
      return;
    }

    //stop loading
    Navigator.of(context).pop();

    //substitution options
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Here are a list of substitutes for ${widget.title}',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          content: Container(
            width: double.maxFinite, // Make the container as wide as the dialog
            child: ListView(
              shrinkWrap: true,
              children: substitutions.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.value,
                    style: TextStyle(
                        color: Colors.black), // Set text color to black
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pop(); // Close the substitutions dialog
                    _generateAlteredRecipe(entry.value,
                        widget.title); // Generate the altered recipe
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFDC945F),
                  width: 1.5,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFDC945F),
                ), // Set text color to black
              ),
            ),
          ],
          backgroundColor: Colors.white, // Set background color to white
        );
      },
    );
  }

  Future<void> _generateAlteredRecipe(
      String substitute, String substitutedIngredient) async {
    //show loading
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Generating altered recipe...',
            style: TextStyle(color: Colors.black), // Set text color to black
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Replace CircularProgressIndicator with your custom loading animation
              Lottie.asset(
                'assets/loading.json', // Path to your Lottie file
                // width: 100,
                // height: 100,
                // fit: BoxFit.fill,
              ),
            ],
          ),
          backgroundColor: Colors.white, // Set background color to white
        );
      },
    );
    //fetch the altered rec
    String jsonString = await fetchIngredientSubstitutionRecipe(
        widget.recipeID, substitute, substitutedIngredient);

    //stop loading
    Navigator.of(context).pop();

    // Parse the JSON string
    Map<String, dynamic> alteredRecipe = jsonDecode(jsonString);

    //update the altered recipe
    widget.onRecipeUpdate(alteredRecipe);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color textColor =
        isLightTheme ? Color.fromARGB(255, 19, 20, 20) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            
              SizedBox(
                width: 24.0, // to keep alignment when checkbox is missing
              ),
            // Constrain the width of the text
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add Flexible here to limit the width of the Text widget
                  Flexible(
                    child: Text(
                      widget.title,
                      overflow:
                          TextOverflow.ellipsis, // Truncate text with ellipsis
                      maxLines: 1, // Only allow a single line of text
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.swap_horiz, color: textColor),
                    onPressed: _showSubstitutesDialog,
                    color: textColor,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ],
    );
  }


  
}
