import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'help_pantry.dart';
import 'dart:html' as html; // For web
import 'dart:io'; // For mobile
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;
// import 'dart:io';
import '../widgets/theme_utils.dart';
import '../gemini_service.dart'; // LLM
//import 'dart:convert';


class PantryScreen extends StatefulWidget {
  final http.Client? client;

  PantryScreen({Key? key, this.client}) : super(key: key);
  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String? _userId;
  OverlayEntry? _helpMenuOverlay;
  //String measurementUnit = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await _loadUserId();
    await _fetchIngredientNames();
    _loadDontShowAgainPreference();
    await _fetchPantryList();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final Map<String, List<String>> _pantryList = {};
  final Map<String, bool> _checkboxStates = {};

  List<Map<String, String>> _items = [];

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
      });
    }
  }

  Future<void> _fetchIngredientNames() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: '{"action": "getIngredientNames"}',
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Cache the response for offline use
        await prefs.setString('cachedIngredients', jsonEncode(data));
        if (mounted) {
          setState(() {
            _items = data
                .map((item) => {
                      'id': item['id'].toString(),
                      'name': item['name'].toString(),
                      'category': item['category'].toString(),
                      'measurementUnit': item['measurementUnit'].toString(),
                    })
                .toList();

            // Sort items alphabetically by name
            _items.sort((a, b) => a['name']!.compareTo(b['name']!));
          });
        }
      } else {
        print('Failed to fetch ingredient names: ${response.statusCode}');
      }
    } catch (error) {
      //print('Error fetching ingredient names: $error');

      // Load from cache if the network fails
      final cachedData = prefs.getString('cachedIngredients');
      if (cachedData != null) {
        final List<dynamic> data = jsonDecode(cachedData);
        if(mounted){
        setState(() {
          _items = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'name': item['name'].toString(),
                    'category': item['category'].toString(),
                    'measurementUnit': item['measurementUnit'].toString(),
                  })
              .toList();

          // Sort items alphabetically by name
          _items.sort((a, b) => a['name']!.compareTo(b['name']!));
        });}
      }
    }
  }
  
Future<void> _fetchPantryList() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Fetch data from the API
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'getAvailableIngredients',
          'userId': _userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> pantryList = data['availableIngredients'];

        // Cache the response data
        await prefs.setString('cachedPantryList', jsonEncode(pantryList));

      // Process and update the pantry list
      if (mounted) {
        setState(() {
          _pantryList.clear();
          for (var item in pantryList) {
            final ingredientName = item['name'].toString();
            final quantity = item['quantity'].toString();
            final measurementUnit = item['measurmentunit'].toString();
            final category = item['category'] ?? 'Other';
            final displayText = '$ingredientName ($quantity $measurementUnit)';

              _pantryList.putIfAbsent(category, () => []);
              _pantryList[category]?.add(displayText);
            }

            // Sort items within each category alphabetically
            _pantryList.forEach((category, items) {
              items.sort((a, b) => a.compareTo(b));
            });
          });
        }
      } else {
        print('Failed to fetch pantry list: ${response.statusCode}');
      }
    } catch (error) {
      // Print error and use cached data if network request fails
      final cachedData = prefs.getString('cachedPantryList');
      if (cachedData != null) {
        final List<dynamic> pantryList = jsonDecode(cachedData);

      if (mounted) {
        setState(() {
          _pantryList.clear();
          for (var item in pantryList) {
            final ingredientName = item['name'].toString();
            final quantity = item['quantity'].toString();
            final measurementUnit = item['measurmentunit'].toString();
            final category = item['category'] ?? 'Other';
            final displayText = '$ingredientName ($quantity $measurementUnit)';

              _pantryList.putIfAbsent(category, () => []);
              _pantryList[category]?.add(displayText);
            }

            // Sort items within each category alphabetically
            _pantryList.forEach((category, items) {
              items.sort((a, b) => a.compareTo(b));
            });
          });
        }
      }
    }
  }


  Future<void> _addToPantryList(String? userId, String ingredientName,
      double quantity, String measurementUnit) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'addToPantryList', // Change action to addToPantryList
          'userId': userId,
          'ingredientName': ingredientName,
          'quantity': quantity,
          'measurementUnit': measurementUnit,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        //print('Successfully added $ingredientName to pantry list');
      } else {
        print(
            'Failed to add $ingredientName to pantry list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding $ingredientName to pantry list: $error');
    }
  }

  Future<void> _editPantryItem(String category, String item, double quantity,
      String measurementUnit) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'editPantryItem',
          'userId': _userId,
          'ingredientName': item,
          'quantity': quantity,
          'measurementUnit': measurementUnit,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {

            final displayText = '$item ($quantity $measurementUnit)';
            if (_pantryList[category] != null) {
              final index = _pantryList[category]!
                  .indexWhere((ingredient) => ingredient.startsWith(item));
              if (index != -1) {
                _pantryList[category]![index] = displayText;
              }
            }
          });
        }
        print(
            'Successfully edited $item in pantry list with quantity $quantity $measurementUnit');
      } else {
        print('Failed to edit $item in pantry list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error editing $item in pantry list: $error');
    }
  }

  Future<void> _removeFromPantryList(String category, String item) async {
    // Extract the ingredient name from the item string
    final parts = item.split(' (');
    String ingredientName = parts[0];

    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'removeFromPantryList',
          'userId': _userId,
          'ingredientName': ingredientName,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _pantryList[category]?.remove(item);
            if (_pantryList[category]?.isEmpty ?? true) {
              _pantryList.remove(category);
            }
          });
        }
        print('Successfully removed $ingredientName from pantry list');
      } else {
        print(
            'Failed to remove $ingredientName from pantry list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing $ingredientName from pantry list: $error');
    }
  }

  // ignore: unused_field
  bool _dontShowAgain = false;

  Future<void> _loadDontShowAgainPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _dontShowAgain = prefs.getBool('dontShowAgain') ?? false;
      });
    }
  }

  void _addItem(String category, String item, bool type, double quantity,
      String measurementUnit) {
    if (type) {
      // Do nothing
    } else {
      if (mounted) {
        setState(() {
          final displayText = '$item ($quantity $measurementUnit)';
          _pantryList.putIfAbsent(category, () => []).add(displayText);
          _checkboxStates[displayText] = false;
        });
      }
      _addToPantryList(
          _userId, item, quantity, measurementUnit); // New line for pantry list
    }
  }

Future<String> _getIngredientDetails(String ingredientName) async {
    print("in _getIngredientDetails function");
    try {
      final response = await http.post(
        Uri.parse(
            'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
        body: jsonEncode({
          'action': 'getIngredientDetails', 
          'ingredientName': ingredientName,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('it worked lol');
        final Map<String, dynamic> ingredientDetails = jsonDecode(response.body);
        print('Ingredient Details: $ingredientDetails');

        final List<dynamic> ingredientData = ingredientDetails['ingredientData'];

        // Access the first ingredient's measurement unit
        final String measurementUnit = ingredientData[0]['measurement_unit'].toString();

        print('Ingredient Measurement Unit: $measurementUnit');

        return measurementUnit;
      } else {
        print('Failed: ${response.statusCode}');
        return '';
      }
    } catch (error) {
      print('INGREDIENT DETAILS: Error fetching $ingredientName: $error');
      return '';
    }
  }



  void _showHelpMenu() {
    _helpMenuOverlay = OverlayEntry(
      builder: (context) => HelpMenu(
        onClose: () {
          _helpMenuOverlay?.remove();
          _helpMenuOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_helpMenuOverlay!);
  }

  Future<void> _scanImage() async {
  if (kIsWeb) {
    // Web-specific code
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);

      reader.onLoadEnd.listen((_) async {
        final base64Image = reader.result.toString().split(',').last;
        final text = await _extractTextFromImage(base64Image);
        if (text.isNotEmpty) {
          print(text);
          await _handleScannedText(text);
        }
      });
    });
  } else {
    // Mobile-specific code
    if (await Permission.camera.request().isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageBytes = File(pickedFile.path).readAsBytesSync();
        final text = await _extractTextFromImage(imageBytes);
        if (text.isNotEmpty) {
          await _handleScannedText(text);
        }
      }
    }
  }
}

Future<void> _selectImage() async {
  if (kIsWeb) {
    // Web-specific code
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);

      reader.onLoadEnd.listen((_) async {
        final base64Image = reader.result.toString().split(',').last;
        final text = await _extractTextFromImage(base64Image);
        if (text.isNotEmpty) {
          await _handleScannedText(text);
        }
      });
    });
  } else {
    // Mobile-specific code
    if (await Permission.photos.request().isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageBytes = File(pickedFile.path).readAsBytesSync();
        final text = await _extractTextFromImage(imageBytes);
        if (text.isNotEmpty) {
          await _handleScannedText(text);
        }
      }
    }
  }
}

Future<void> _showIngredientDialog(List<String> ingredients) async {
  List<String> growableIngredients = List.from(ingredients); // Make it growable
  List<String> selectedIngredients = []; // Store selected ingredients
  List<String> quantities = []; // Store quantities
  List<String> measurementUnits = []; // Store measurement units
  List<TextEditingController> controllers = []; // List of controllers for quantities

  // Populate selectedIngredients, quantities, measurementUnits, and controllers dynamically
  for (var _ in growableIngredients) {
    selectedIngredients.add(''); // Initialize with empty values
    quantities.add(''); // Initialize with empty quantities
    measurementUnits.add(''); // Initialize with empty measurement units
    controllers.add(TextEditingController()); // Add a new controller for each ingredient
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Detected Ingredients'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: growableIngredients.asMap().entries.map((entry) {
                  int index = entry.key;
                  String itemEntry = entry.value;

                  // Extract itemName and identifiedIngredient from the entry
                  final itemParts = itemEntry.split(',');
                  final itemName = itemParts.isNotEmpty ? itemParts[0].replaceFirst('Item: ', '').trim() : '';
                  final identifiedIngredient = itemParts.length > 1 ? itemParts[1].replaceFirst('Ingredient: ', '').trim() : '';

                  return FutureBuilder<List<String>>(
                    future: findSimilarIngredients(itemName, identifiedIngredient), // Call Dart function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text(itemName),
                          trailing: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text(itemName),
                          trailing: Text('Error loading similar ingredients'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return ListTile(
                          title: Text(itemName),
                          trailing: Text('No similar ingredients found'),
                        );
                      }

                      final similarIngredients = snapshot.data!;
                      if (selectedIngredients[index].isEmpty && similarIngredients.isNotEmpty) {
                        selectedIngredients[index] = similarIngredients.first;
                      }

                      return FutureBuilder<String>(
                        future: _getIngredientDetails(selectedIngredients[index]),
                        builder: (context, detailsSnapshot) {
                          if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text(itemName),
                              trailing: CircularProgressIndicator(),
                            );
                          } else if (detailsSnapshot.hasError) {
                            return ListTile(
                              title: Text(itemName),
                              trailing: Text('Error fetching details'),
                            );
                          } else if (!detailsSnapshot.hasData || detailsSnapshot.data!.isEmpty) {
                            return ListTile(
                              title: Text(itemName),
                              trailing: Text('No details found'),
                            );
                          }

                          // Extract the measurement unit from the ingredient details
                          String measurementUnit = detailsSnapshot.data ?? 'unit'; // Default to 'unit' if no data

                          // Store the measurement unit in the list for later use
                          measurementUnits[index] = measurementUnit;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: ListTile(
                                  title: Text(itemName),
                                  trailing: DropdownButton<String>(
                                    value: selectedIngredients[index].isNotEmpty &&
                                            similarIngredients.contains(selectedIngredients[index])
                                        ? selectedIngredients[index]
                                        : null, // If value is not in the list, set it to null
                                    hint: Text('Select similar ingredient'),
                                    items: similarIngredients.map((ingredient) {
                                      return DropdownMenuItem<String>(
                                        value: ingredient,
                                        child: Text(ingredient),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedIngredients[index] = newValue ?? '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controllers[index], // Use the correct controller
                                          decoration: InputDecoration(hintText: 'Qty'),
                                          onChanged: (value) {
                                            quantities[index] = value; // Update the quantities list
                                          },
                                        ),
                                      ),
                                      Text(measurementUnit), // Display the measurement unit
                                      IconButton(
                                        icon: Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            growableIngredients.removeAt(index);
                                            selectedIngredients.removeAt(index);
                                            quantities.removeAt(index);
                                            measurementUnits.removeAt(index);
                                            controllers.removeAt(index); // Remove the controller as well
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                    // Loop through all selected ingredients and add them to the pantry
                    for (var i = 0; i < selectedIngredients.length; i++) {
                      final selected = selectedIngredients[i];
                      final quantity = quantities[i];
                      final measurementUnit = measurementUnits[i];

                      // Ensure valid ingredient and quantity are provided before adding to pantry
                      if (selected.isNotEmpty && quantity.isNotEmpty && measurementUnit.isNotEmpty) {
                        await _addToPantryList(_userId, selected, double.parse(quantity), measurementUnit);
                      }
                    }

                    Navigator.of(context).pop(); // Close the dialog after adding to pantry
                    await _fetchPantryList();
                  },

                child: Text('Add to Pantry'),
              ),
            ],
          );
        },
      );
    },
  );
}





Future<List<String>> findSimilarIngredients(String itemName, String identifiedIngredient) async {
  final prefs = await SharedPreferences.getInstance();

  try {
    final requestBody = jsonEncode({
      'action': 'findSimilarIngredients',
      'itemName': itemName,
      'identifiedIngredient': identifiedIngredient,
    });

    // Send the POST request to your Supabase Function to get ingredients from the DB
    final response = await http.post(
      Uri.parse(
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'
      ),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      // Decode the response body as a list of ingredients
      final List<dynamic> dbIngredients = jsonDecode(response.body);

      // Use Gemini to find the most appropriate ingredient
      final bestMatch = await findBestMatchingIngredient(identifiedIngredient, dbIngredients.map((e) => e['name'].toString()).toList());

      // Ensure the best match is the first in the list, followed by the rest of the ingredients
      List<String> sortedIngredients = [bestMatch];
      sortedIngredients.addAll(dbIngredients.map<String>((ingredient) => ingredient['name'].toString()).where((ingredient) => ingredient != bestMatch).toList());

      // Cache the response for offline use (optional)
      await prefs.setString('cachedSimilarIngredients', jsonEncode(dbIngredients));

      return sortedIngredients;
    } else {
      print('Failed to fetch similar ingredients: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    print('Error fetching similar ingredients: $error');

    // Fallback to cached data in case of network failure
    final cachedData = prefs.getString('cachedSimilarIngredients');
    if (cachedData != null) {
      final List<dynamic> data = jsonDecode(cachedData);
      return data.map<String>((ingredient) => ingredient['name'].toString()).toList();
    }

    return [];
  }
}




Future<String> _extractTextFromImage(dynamic imageData) async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }
  final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

  String base64Image;

  if (kIsWeb) {
    // For Web, imageData is a Base64-encoded string
    base64Image = imageData;
  } else {
    // For Mobile, convert Uint8List to Base64 string
    base64Image = base64Encode(imageData);
  }

  final requestPayload = json.encode({
    'requests': [
      {
        'image': {
          'content': base64Image,
        },
        'features': [
          {
            'type': 'TEXT_DETECTION',
            'maxResults': 1,
          },
        ],
      },
    ],
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: requestPayload,
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      final textAnnotations = responseJson['responses'][0]['textAnnotations'];
      if (textAnnotations != null && textAnnotations.isNotEmpty) {
        return textAnnotations[0]['description'];
      } else {
        return 'No text detected.';
      }
    } else {
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
      print('Response body: ${response.body}');
      return 'Failed to detect text from image';
    }
  } catch (e) {
    print('Exception: $e');
    return 'Failed to detect text from image';
  }
}


Future<void> _handleScannedText(String text) async {
  print(text);
  final items = _parseIngredientsFromText(text);

  // Convert List<String> to a single String
  final itemsString = items.join('\n');

  // Await the result of the identifyIngredientFromReceipt function
  final ingredients = await identifyIngredientFromReceipt(itemsString);
  print("INGREDIENTS");
  print(ingredients);

  // Parse the ingredients list to extract both items and ingredients in pairs
  final pairedItemsIngredients = <Map<String, String>>[];

  for (var entry in ingredients) {
    final itemMatch = RegExp(r'Item: ([^,]+)').firstMatch(entry);
    final ingredientMatch = RegExp(r'Ingredient: (.+)').firstMatch(entry);

    if (itemMatch != null && ingredientMatch != null) {
      final item = itemMatch.group(1)?.trim();
      final ingredient = ingredientMatch.group(1)?.trim();

      if (item != null && ingredient != null) {
        pairedItemsIngredients.add({'item': item, 'ingredient': ingredient});
      }
    }
  }

  // Filter out any pairs where the ingredient contains unwanted keywords
  final filteredPairs = pairedItemsIngredients.where((pair) {
    final lowerIngredient = pair['ingredient']!.toLowerCase();
    
    // Check if the ingredient contains 'drink', 'soap', or other unwanted keywords
    return !lowerIngredient.contains('drink') &&
           !lowerIngredient.contains('soap'); // Add more filters here
  }).toList();

  // Prepare the filtered list for display
  final filteredItems = filteredPairs
      .map((pair) => 'Item: ${pair['item']}, Ingredient: ${pair['ingredient']}')
      .toList();

  // Show the appropriate dialog based on the filtered results
  if (filteredItems.isNotEmpty) {
    _showIngredientDialog(filteredItems);
  } else {
    _showNoIngredientsFoundDialog();
  }
}

List<String> _parseIngredientsFromText(String text) {
  final lowerCaseText = text.toLowerCase();

  final firstLine = lowerCaseText.split('\n').first;
  print(firstLine);
  
  final store = detectStoreFormat(firstLine);

  return parseReceiptForStore(lowerCaseText, store);
}

String detectStoreFormat(String text) {
  // checks which one of the stores the line passed in is to modify the parsing accordingly
  if (text.contains('pick n pay')) {
    print("first line is pick n pay");
    return "P"; // Pick n Pay
  } else if (text.contains('woolworths')) {
    print("first line is woolworths");
    return "W"; // Woolworths
  } else if (text.contains('checkers')) {
    print("first line is checkers");
    return "C"; // Checkers
  }
  print("couldn't find store name");
  return "U"; // Unknown
}

// Function to parse receipt based on detected store
List<String> parseReceiptForStore(String text, String store) {
  switch (store) {
    case "P":
      print("going to parse Pick n Pay receipt");
      return parsePicknPayReceipt(text);
    case "W":
      print("going to parse Woolworths receipt");
      return parseWoolworthsReceipt(text);
    case "C":
    print("going to parse Checkers receipt");
      return parseCheckersReceipt(text);
    default:
      return []; // Handle unknown or unsupported formats
  }
}

// Store-specific parsing functions
List<String> parsePicknPayReceipt(String text) {
  // FORMAT
  // Pick n Pay
  // location
  // phone number
  // CASHIER: ****

  // item name (required)
  //        quantity      @      price   (optional -- only if > 1)
  // ** Less cash-off (optional if discounted)
  // .
  // .
  // .
  // DUE VAT INCL

  final lowerCaseText = text.toLowerCase();
  
  final startMarker = 'cashier:';
  final endMarker = 'due vat incl';
  
  final startIndex = lowerCaseText.indexOf(startMarker);
  final endIndex = lowerCaseText.indexOf(endMarker);

  // Check if both markers are found and in correct order
  if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
    return []; 
  }

  final startOffset = lowerCaseText.indexOf('\n', startIndex) + 1; 
  final section = lowerCaseText.substring(startOffset, endIndex).trim();
  
  final lines = section.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
  // print("LINES");
  // print(lines);

  final items = <String>[];
  
  String? currentItem;

  for (var line in lines) {
    // all the skips
    if (line.contains('less cash-off')) {
      continue; // skip discounts
    }

    // remove dog food lol because Gemini doesn't want to
    if (line.contains('dog') || line.contains("d/f")) {
      continue;
    }

    // remove drinks - can add more drinks here
    if (line.contains('drink') || line.contains('jce') || line.contains('juice')) {
      continue;
    }

    if (line.contains(RegExp(r'@')) || line.contains(RegExp(r'\d+\.\d{2}')) || line.startsWith(RegExp(r'\d+'))) {
      // can add quantity stuff here
      continue;
    } else {
      currentItem = line.trim();
      items.add(currentItem);
    }
  }

  // print("ITEMS");
  // print(items);


  return items;
}



List<String> parseWoolworthsReceipt(String text) {
  // FORMAT
  // Welcome to our store
  // other stuff
  // TAX INVOICE
  // -------------------------------------------
  // S | Z item (required)      price
  //   num @ price (optional if num > 1)
  // price (Rxx.xx) less promo price (Rxx.xx) (optional if on promotion)
  // .
  // .
  // .
  // TOTAL

  final lowerCaseText = text.toLowerCase();

  final startMarker = 'tax invoice';
  final endMarker = 'total';

  final startIndex = lowerCaseText.indexOf(startMarker);
  final endIndex = lowerCaseText.indexOf(endMarker);

  // Check if both markers are found and in correct order
  if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
    return [];
  }

  final startOffset = lowerCaseText.indexOf('\n', startIndex) + 1;
  final section = lowerCaseText.substring(startOffset, endIndex).trim();

  final lines = section
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  final items = <String>[];

  String? currentItem;

  for (var line in lines) {
    // Skip promotions and discounts
    if (line.contains('less promo') || line.contains('discount')) {
      continue;
    }

    // Skip drinks, just as in Pick n Pay
    if (line.contains('drink') || line.contains('jce') || line.contains('juice') || line.contains('coke')) {
      continue;
    }

    // Skip price lines and quantity lines (optional)
    if (line.contains(RegExp(r'@')) ||
        line.contains(RegExp(r'r\d+\.\d{2}')) ||
        line.startsWith(RegExp(r'\d+'))) {
      continue;
    } else {
      // Extract the item name
      currentItem = line.trim();
      items.add(currentItem);
    }
  }

  return items;
}


List<String> parseCheckersReceipt(String text) {
  // FORMAT
  // Checkers 
  // company
  // location + number
  // address
  // VAT no.
  // TAX INVOICE
  // item (required)    price
  //        num    @    price (optional if num > 1)
  //  XTRASAVE ... -price (optional - discount)
  // .
  // .
  // .
  // TOTAL[]        price
  final lowerCaseText = text.toLowerCase();

  final startMarker = 'tax invoice';
  final endMarker = 'total';

  final startIndex = lowerCaseText.indexOf(startMarker);
  final endIndex = lowerCaseText.indexOf(endMarker);

  // Check if both markers are found and in correct order
  if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
    return [];
  }

  final startOffset = lowerCaseText.indexOf('\n', startIndex) + 1;
  final section = lowerCaseText.substring(startOffset, endIndex).trim();

  final lines = section.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
  // print("LINES");
  // print(lines);

  final items = <String>[];
  
  String? currentItem;

  for (var line in lines) {
    // Skip quantity lines, prices, and discounts
    if (line.contains(RegExp(r'@')) || line.startsWith(RegExp(r'\d+')) || line.contains('xtrasave')) {
      continue;
    }

    // Add item name
    currentItem = line.trim();
    items.add(currentItem);
  }

  // print("ITEMS");
  // print(items);

  return items;
}


Future<void> _showNoIngredientsFoundDialog() async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('No Ingredients Found'),
        content: Text('No ingredients were detected in the image.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(top: 30, left: 30.0),
          child: Text(
            'Pantry',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              key: Key('help_button'),
              icon: Icon(Icons.help),
              onPressed: _showHelpMenu,
              iconSize: 35,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Lottie.asset('assets/loading.json'))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        Expanded(
                          child: _pantryList.isEmpty
                              ? Center(
                                  child: Text(
                                    "No ingredients have been added. Click the plus icon to add your first ingredient!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView(
                                  children: _pantryList.entries.expand((entry) {
                                    return [
                                      if (entry.value.isNotEmpty) ...[
                                        _buildCategoryHeader(entry.key),
                                      ],
                                      ...entry.value.asMap().entries.map(
                                          (item) => _buildCheckableListItem(
                                              entry.key,
                                              item.value,
                                              item.key % 2 == 1)),
                                    ];
                                  }).toList(),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              ElevatedButton(
                                key: ValueKey('Pantry'),
                                onPressed: () {
                                  _showAddItemDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC945F),
                                  foregroundColor: Colors.white,
                                  fixedSize: const Size(48.0, 48.0),
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.all(0),
                                ),
                                child: const Icon(Icons.add, size: 32.0),
                              ),
                              ElevatedButton(
                                key: ValueKey('UploadPhoto'),
                                onPressed: _selectImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 195, 108, 46),
                                  foregroundColor: Colors.white,
                                  fixedSize: const Size(48.0, 48.0),
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.all(0),
                                ),
                                child: const Icon(Icons.camera_alt, size: 32.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

// Helper method to build a category header
  Widget _buildCategoryHeader(String title) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    final Map<String, IconData> categoryIcons = {
      'Dairy': Icons.icecream,
      'Meat': Icons.kebab_dining,
      'Fish': Icons.pool,
      'Nuts': Icons.sports_rugby_outlined,
      'Spice/Herb': Icons.grass,
      'Starch': Icons.bakery_dining,
      'Vegetable': Icons.local_florist,
      'Vegeterian': Icons.eco_outlined,
      'Fruit': Icons.apple,
      'Legume': Icons.grain, //scatter_plot
      'Staple': Icons.breakfast_dining,
      'Other': Icons.workspaces,
    };

    final Map<String, Color> categoryColors = {
      'Dairy': const Color.fromARGB(255, 255, 190, 24),
      'Meat': Color.fromARGB(255, 163, 26, 16),
      'Fish': Colors.blue,
      'Nuts': Color.fromARGB(255, 131, 106, 98),
      'Spice/Herb': Colors.green,
      'Starch': Colors.orange,
      'Vegetable': Colors.green,
      'Vegeterian': Colors.green,
      'Fruit': Colors.red,
      'Legume': Color.fromARGB(255, 131, 106, 98),
      'Staple': const Color.fromARGB(255, 225, 195, 151),
      'Other': Colors.grey,
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            categoryIcons[title] ?? Icons.category,
            size: 28.0,
            color: categoryColors[title] ?? Colors.orange,
          ),
          SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckableListItem(String category, String item, bool isShaded) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isShaded ? shade(context) : unshade(context),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          key: ValueKey(item),
          title: Text(
            item,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  _showEditItemDialog(context, category, item);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  _removeFromPantryList(category, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditItemDialog(
      BuildContext context, String category, String item) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    double quantity = 1.0; // Default quantity
    String measurementUnit = 'unit'; // Default measurement unit

    // Extract existing quantity and measurement unit from the item string
    final parts = item.split(' (');
    String itemName = parts[0];
    if (parts.length == 2) {
      final quantityParts = parts[1].split(' ');
      if (quantityParts.length == 2) {
        quantity = double.tryParse(quantityParts[0]) ?? 1.0;
        measurementUnit = quantityParts[1].replaceAll(')', '');
      }
    }

    final TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Item',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF283330),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFDC945F)),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a quantity';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          quantity = double.tryParse(value) ??
                              1.0; // Default to 1.0 if parsing fails
                        },
                      ),
                      SizedBox(height: 16.0), // Add spacing for better UI
                      Text('Measurement Unit: $measurementUnit',
                          style: TextStyle(
                              color: Colors
                                  .white)), // Display the measurement unit
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    side: BorderSide(color: Color(0xFFDC945F), width: 1.5),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFFDC945F)),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFDC945F),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      _editPantryItem(
                          category, itemName, quantity, measurementUnit);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    String selectedItem = '';
    double quantity = 1.0; // Default quantity
    String measurementUnit = ''; // Default measurement unit
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

  //print($measurementUnit);
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: ThemeData(
                dialogBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: AlertDialog(
                title: Text('Add Item to Pantry List'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        TypeAheadFormField<Map<String, String>>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: itemNameController,
                            decoration: InputDecoration(labelText: 'Item Name'),
                          ),
                          suggestionsCallback: (pattern) async {
                            return _items.where((item) => item['name']!
                                .toLowerCase()
                                .contains(pattern.toLowerCase()));
                          },
                          itemBuilder:
                              (context, Map<String, String> suggestion) {
                            return ListTile(
                              title: Text(suggestion['name']!),
                            );
                          },
                          onSuggestionSelected:
                              (Map<String, String> suggestion) {
                            itemNameController.text = suggestion['name']!;
                            categoryController.text = suggestion['category']!;
                            selectedItem = suggestion['name']!;
                            if (mounted) {
                              setState(() {
                                measurementUnit = suggestion[
                                    'measurementUnit']!; // Set measurement unit in the state
                              });
                            }
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please select an item';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            selectedItem = value!;
                          },
                        ),
                        TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a quantity';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            quantity = double.tryParse(value) ??
                                1.0; // Default to 1.0 if parsing fails
                          },
                        ),
                        SizedBox(height: 16.0), // Add spacing for better UI
                        Text(
                          
                            'Measurement Unit: $measurementUnit'), // Display the measurement unit
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFDC945F),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFDC945F),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        final category = categoryController.text;
                        _addItem(category, selectedItem, false, quantity,
                            measurementUnit);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
