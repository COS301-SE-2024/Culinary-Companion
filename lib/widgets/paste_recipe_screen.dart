import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../gemini_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class PasteRecipe extends StatefulWidget {
  @override
  _PasteRecipeState createState() => _PasteRecipeState();
}

class _PasteRecipeState extends State<PasteRecipe> {
  String? _userId;
  final TextEditingController _recipeTextController =
      TextEditingController(); //pasted text controller
  List<String> _cuisines = [];
  String? _selectedCuisine;
  List<String> _appliances = [];
  List<String> _selectedAppliances = [];
  List<MultiSelectItem<String>> _applianceItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadCuisines();
    _loadAppliances();
  }

  Future<void> _loadAppliances() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'action': 'getAllAppliances'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _appliances = data.map<String>((appliance) {
              return appliance['name'].toString();
            }).toList();
            _applianceItems = _appliances
                .map((appliance) =>
                    MultiSelectItem<String>(appliance, appliance))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      throw Exception('Error fetching appliances: $e');
    }
  }

  Future<void> _loadCuisines() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'action': 'getCuisines'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            // Ensure the UI updates after cuisines are loaded
            _cuisines = data.map<String>((cuisine) {
              return cuisine['name'].toString();
            }).toList();
          });
        }
        //print(_cuisines);
      } else {
        throw Exception('Failed to load cuisines');
      }
    } catch (e) {
      throw Exception('Error fetching cuisines: $e');
    }
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
      final response =
          await supabase.storage.from('recipe_photos').uploadBinary(
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

  String capitalizeEachWord(String input) {
    //ensure proper capitalization of ingredients
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  double parseQuantity(String quantity) {
    //make sure quantity is numeric
    if (quantity.contains('/')) {
      List<String> parts = quantity.split('/');
      if (parts.length == 2) {
        double numerator = double.tryParse(parts[0].trim()) ?? 1.0;
        double denominator = double.tryParse(parts[1].trim()) ?? 1.0;
        return numerator / denominator;
      }
    }
    return double.tryParse(quantity) ?? 1.0; //defult if empty
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final extractedRecipeData = await extractRecipeData(
          pastedText, _selectedImage ?? _preloadedImages[0]);
      print("extracted data: $extractedRecipeData");

      if (extractedRecipeData != null &&
          !extractedRecipeData.containsKey('error')) {
        // split steps
        if (extractedRecipeData.containsKey('methods')) {
          extractedRecipeData['methods'] =
              extractedRecipeData['methods'].split('<');
        }

        // if cusine is null
        extractedRecipeData['cuisine'] =
            extractedRecipeData['cuisine'] ?? 'American';

        await _showRecipeConfirmationDialog(context, extractedRecipeData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract recipe data.')),
        );
      }
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showRecipeConfirmationDialog(
      BuildContext context, Map<String, dynamic> recipeData) async {
    final TextEditingController nameController =
        TextEditingController(text: recipeData['name']);
    final TextEditingController descriptionController =
        TextEditingController(text: recipeData['description']);
    final TextEditingController cookTimeController =
        TextEditingController(text: recipeData['cookTime'].toString());
    final TextEditingController prepTimeController =
        TextEditingController(text: recipeData['prepTime'].toString());

    final TextEditingController courseController =
        TextEditingController(text: recipeData['course']);
    final TextEditingController servingAmountController =
        TextEditingController(text: recipeData['servingAmount'].toString());

    final TextEditingController spiceLevelController =
        TextEditingController(text: recipeData['spiceLevel'].toString());

    final List<TextEditingController> ingredientNameControllers = [];
    final List<TextEditingController> ingredientQuantityControllers = [];
    final List<TextEditingController> ingredientUnitControllers = [];

    for (var ingredient in recipeData['ingredients']) {
      ingredientNameControllers
          .add(TextEditingController(text: ingredient['name']));
      ingredientQuantityControllers
          .add(TextEditingController(text: ingredient['quantity'].toString()));
      ingredientUnitControllers
          .add(TextEditingController(text: ingredient['unit']));
    }

    final List<TextEditingController> methodControllers = [];
    for (var step in recipeData['methods']) {
      methodControllers.add(TextEditingController(text: step));
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirm Recipe'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Recipe Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCuisine ??
                          recipeData[
                              'cuisine'], // Initialize selected value from recipeData
                      items: _cuisines
                          .map((cuisine) => DropdownMenuItem<String>(
                                value: cuisine,
                                child: Text(cuisine),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCuisine = value;
                          recipeData['cuisine'] = value ??
                              recipeData['cuisine']; // Update recipeData
                        });
                        print('Selected Cuisine: $value'); // Debugging line
                        print('Updated RecipeData: ${recipeData['cuisine']}');
                      },
                      decoration: InputDecoration(labelText: 'Cuisine'),
                    ),
                    TextField(
                      controller: cookTimeController,
                      decoration:
                          InputDecoration(labelText: 'Cook Time (minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: prepTimeController,
                      decoration:
                          InputDecoration(labelText: 'Prep Time (minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: recipeData[
                          'course'], // Initialize selected value from recipeData
                      items: ['Breakfast', 'Main', 'Dessert', 'Appetizer']
                          .map((course) => DropdownMenuItem<String>(
                                value: course,
                                child: Text(course),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          recipeData['course'] = value ??
                              recipeData['course']; // Update recipeData
                        });
                        print('Selected Course: $value'); // Debugging line
                        print('Updated RecipeData: ${recipeData['course']}');
                      },
                      decoration: InputDecoration(labelText: 'Course'),
                    ),
                    TextField(
                      controller: servingAmountController,
                      decoration: InputDecoration(labelText: 'Serving Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<int>(
                      value: recipeData['spiceLevel'] is int
                          ? recipeData['spiceLevel']
                          : int.tryParse(recipeData['spiceLevel'].toString()) ??
                              1, // Initialize selected value
                      items: [
                        DropdownMenuItem<int>(value: 1, child: Text('None')),
                        DropdownMenuItem<int>(value: 2, child: Text('Mild')),
                        DropdownMenuItem<int>(value: 3, child: Text('Medium')),
                        DropdownMenuItem<int>(value: 4, child: Text('Hot')),
                        DropdownMenuItem<int>(
                            value: 5, child: Text('Extra Hot')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          recipeData['spiceLevel'] =
                              value ?? 1; // Update recipeData
                        });
                        print('Selected Spice Level: $value'); // Debugging line
                        print(
                            'Updated RecipeData: ${recipeData['spiceLevel']}');
                      },
                      decoration: InputDecoration(labelText: 'Spice Level'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(
                        ingredientNameControllers.length,
                        (index) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        ingredientNameControllers[index],
                                    decoration: InputDecoration(
                                        labelText: 'Ingredient Name'),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      ingredientNameControllers.removeAt(index);
                                      ingredientQuantityControllers
                                          .removeAt(index);
                                      ingredientUnitControllers.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                            TextField(
                              controller: ingredientQuantityControllers[index],
                              decoration:
                                  InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: ingredientUnitControllers[index],
                              decoration: InputDecoration(labelText: 'Unit'),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          ingredientNameControllers
                              .add(TextEditingController());
                          ingredientQuantityControllers
                              .add(TextEditingController());
                          ingredientUnitControllers
                              .add(TextEditingController());
                        });
                      },
                      child: Text('Add Ingredient'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Methods:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(
                        methodControllers.length,
                        (index) => Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: methodControllers[index],
                                decoration: InputDecoration(
                                    labelText: 'Step ${index + 1}'),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  methodControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          methodControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add Step'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Appliances:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    MultiSelectDialogField<String>(
                      items: _applianceItems,
                      initialValue: _selectedAppliances.isEmpty
                          ? recipeData['appliances']
                              .map<String>(
                                  (appliance) => appliance['name'] as String)
                              .toList()
                          : _selectedAppliances,
                      title: Text("Appliances"),
                      selectedColor: Colors.blue,
                      onConfirm: (results) {
                        setState(() {
                          _selectedAppliances = results;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); //close popup
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // update recipe details
                    recipeData['name'] = nameController.text;
                    recipeData['description'] = descriptionController.text;
                    recipeData['cuisine'] =
                        _selectedCuisine ?? recipeData['cuisine'];
                    recipeData['cookTime'] =
                        int.tryParse(cookTimeController.text) ?? 0;
                    recipeData['prepTime'] =
                        int.tryParse(prepTimeController.text) ?? 0;
                    //recipeData['course'] = courseController.text;
                    recipeData['course'] =
                        recipeData['course']; // Use selected course

                    recipeData['servingAmount'] =
                        int.tryParse(servingAmountController.text) ?? 0;
                    //recipeData['spiceLevel'] = int.tryParse(spiceLevelController.text) ?? 1;
                    recipeData['spiceLevel'] = recipeData['spiceLevel'];

                    recipeData['ingredients'] = List.generate(
                      ingredientNameControllers.length,
                      (index) => {
                        'name': capitalizeEachWord(
                            ingredientNameControllers[index].text.trim()),
                        'quantity': parseQuantity(
                            ingredientQuantityControllers[index].text.trim()),
                        'unit': ingredientUnitControllers[index].text.trim(),
                      },
                    );

                    recipeData['methods'] = methodControllers
                        .map((controller) => controller.text)
                        .toList()
                        .join('<'); // join steps

                    recipeData['appliances'] =
                        _selectedAppliances //list of appliances
                            .map((appliance) => {'name': appliance})
                            .toList();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Recipe added successfully!')),
                    );

                    // close popup
                    Navigator.of(context).pop();

                    // submit rec
                    await addExtractedRecipeToDatabase(recipeData, _userId!);
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
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
                    borderSide: BorderSide(color: Colors.grey),
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
              backgroundColor: isLightTheme ? Colors.white : Color(0xFF1F4539),
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
