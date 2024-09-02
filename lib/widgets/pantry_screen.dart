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
import 'dart:io' show Platform;
// import 'dart:io';
import '../widgets/theme_utils.dart';

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

      setState(() {
        _items = data
            .map((item) => {
                  'id': item['id'].toString(),
                  'name': item['name'].toString(),
                  'category': item['category'].toString(),
                  'measurementUnit': item['measurementUnit'].toString(),
                })
            .toList();
      });
    } else {
      print('Failed to fetch ingredient names: ${response.statusCode}');
    }
  } catch (error) {
    //print('Error fetching ingredient names: $error');

    // Load from cache if the network fails
    final cachedData = prefs.getString('cachedIngredients');
    if (cachedData != null) {
      final List<dynamic> data = jsonDecode(cachedData);
      setState(() {
        _items = data
            .map((item) => {
                  'id': item['id'].toString(),
                  'name': item['name'].toString(),
                  'category': item['category'].toString(),
                  'measurementUnit': item['measurementUnit'].toString(),
                })
            .toList();
      });
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
            final measurementUnit = item['measurementunit'].toString();
            final category = item['category'] ?? 'Other';
            final displayText = '$ingredientName ($quantity $measurementUnit)';

            _pantryList.putIfAbsent(category, () => []);
            _pantryList[category]?.add(displayText);
          }
        });
      }
    } else {
      print('Failed to fetch pantry list: ${response.statusCode}');
    }
  } catch (error) {
    //print('Error fetching pantry list: $error');

    // Load cached data if the network request fails
    final cachedData = prefs.getString('cachedPantryList');
    if (cachedData != null) {
      final List<dynamic> pantryList = jsonDecode(cachedData);

      if (mounted) {
        setState(() {
          _pantryList.clear();
          for (var item in pantryList) {
            final ingredientName = item['name'].toString();
            final quantity = item['quantity'].toString();
            final measurementUnit = item['measurementunit'].toString();
            final category = item['category'] ?? 'Other';
            final displayText = '$ingredientName ($quantity $measurementUnit)';

            _pantryList.putIfAbsent(category, () => []);
            _pantryList[category]?.add(displayText);
          }
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


// final ImagePicker _picker = ImagePicker();
  Future<XFile?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
  XFile? pickedFile;

  if (kIsWeb) {
    // For Web, only allow picking an image from gallery
    pickedFile = await picker.pickImage(source: ImageSource.gallery);
  } else {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await _requestPermissions(context)) {
        pickedFile = await showModalBottomSheet<XFile?>(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take a picture'),
                    onTap: () async {
                      Navigator.of(context).pop(await picker.pickImage(source: ImageSource.camera));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Upload from gallery'),
                    onTap: () async {
                      Navigator.of(context).pop(await picker.pickImage(source: ImageSource.gallery));
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        _showPermissionDeniedMessage(context);
        return null;
      }
    } else {
      throw UnsupportedError('This platform is not supported');
    }
  }

  return pickedFile;
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
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Detected Ingredients'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ingredients.map((ingredient) {
            return ListTile(
              title: Text(ingredient),
              trailing: ElevatedButton(
                onPressed: () {
                  // add to pantry here lol 
                  Navigator.of(context).pop();
                },
                child: Text('Add to Pantry'),
              ),
            );
          }).toList(),
        ),
      );
    },
  );
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
  final ingredients = _parseIngredientsFromText(text);
  if (ingredients.isNotEmpty) {
    _showIngredientDialog(ingredients);
  } else {
    _showNoIngredientsFoundDialog();
  }
}

List<String> _parseIngredientsFromText(String text) {
  final ingredients = <String>[];
  
  // Split the text by new lines or commas, and trim whitespace from each item
  final lines = text.split(RegExp(r'\n|,\s*'));
  
  for (var line in lines) {
    final trimmedLine = line.trim();
    
    if (trimmedLine.isNotEmpty) {
      ingredients.add(trimmedLine);
    }
  }
  
  return ingredients;
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

  Future<bool> _requestPermissions(BuildContext context) async {
    PermissionStatus cameraPermission = await Permission.camera.request();
    PermissionStatus galleryPermission = await Permission.photos.request();

    if (cameraPermission != PermissionStatus.granted ||
        galleryPermission != PermissionStatus.granted) {
      // Handle permission denied scenario
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Camera or gallery permission is required.'),
      ));
      return true;
    } else {
      return false;
    }
  }

  void _showPermissionDeniedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permission denied. You cannot use the camera.'),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: Padding(
        padding: EdgeInsets.only(top: 30, left: 38.0),
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
                              onPressed: () {
                                _showImageSourceSelection(); // Added method to choose image source
                              },
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

void _showImageSourceSelection() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Select Image Source'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _scanImage(); // Use camera
            },
            child: Text('Take Photo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectImage(); // Use gallery
            },
            child: Text('Choose from Gallery'),
          ),
        ],
      );
    },
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
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Item',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: unshade(context),
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
                            borderSide: BorderSide(color: Colors.orange),
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

    await showDialog(
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
