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
    final extractedRecipeData = await extractRecipeData(pastedText, _selectedImage ?? _preloadedImages[0]);
    print("extracted data: $extractedRecipeData");

    if (extractedRecipeData != null && !extractedRecipeData.containsKey('error')) {
      // Split methods into a list of steps
      if (extractedRecipeData.containsKey('methods')) {
        extractedRecipeData['methods'] = extractedRecipeData['methods'].split('<');
      }

      // Handle null or empty cuisine
      extractedRecipeData['cuisine'] = extractedRecipeData['cuisine'] ?? 'American';

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
  final TextEditingController cuisineController =
      TextEditingController(text: recipeData['cuisine']);
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
    ingredientNameControllers.add(
        TextEditingController(text: ingredient['name']));
    ingredientQuantityControllers.add(
        TextEditingController(text: ingredient['quantity'].toString()));
    ingredientUnitControllers.add(
        TextEditingController(text: ingredient['unit']));
  }

  final List<TextEditingController> methodControllers = [];
  for (var step in recipeData['methods']) {
    methodControllers.add(TextEditingController(text: step));
  }

  final List<String> appliances = List<String>.from(
      recipeData['appliances'].map((appliance) => appliance['name']));
  final List<TextEditingController> applianceControllers = appliances
      .map((appliance) => TextEditingController(text: appliance))
      .toList();

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
                  TextField(
                    controller: cuisineController,
                    decoration: InputDecoration(labelText: 'Cuisine'),
                  ),
                  TextField(
                    controller: cookTimeController,
                    decoration: InputDecoration(labelText: 'Cook Time (minutes)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: prepTimeController,
                    decoration: InputDecoration(labelText: 'Prep Time (minutes)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: courseController,
                    decoration: InputDecoration(labelText: 'Course'),
                  ),
                  TextField(
                    controller: servingAmountController,
                    decoration: InputDecoration(labelText: 'Serving Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: spiceLevelController,
                    decoration: InputDecoration(labelText: 'Spice Level'),
                    keyboardType: TextInputType.number,
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
                                  controller: ingredientNameControllers[index],
                                  decoration: InputDecoration(labelText: 'Ingredient Name'),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    ingredientNameControllers.removeAt(index);
                                    ingredientQuantityControllers.removeAt(index);
                                    ingredientUnitControllers.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                          TextField(
                            controller: ingredientQuantityControllers[index],
                            decoration: InputDecoration(labelText: 'Quantity'),
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
                        ingredientNameControllers.add(TextEditingController());
                        ingredientQuantityControllers.add(TextEditingController());
                        ingredientUnitControllers.add(TextEditingController());
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
                              decoration: InputDecoration(labelText: 'Step ${index + 1}'),
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
                  Column(
                    children: List.generate(
                      applianceControllers.length,
                      (index) => Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: applianceControllers[index],
                              decoration: InputDecoration(labelText: 'Appliance'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                applianceControllers.removeAt(index);
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
                        applianceControllers.add(TextEditingController());
                      });
                    },
                    child: Text('Add Appliance'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Update recipeData with the new values from the controllers
                  recipeData['name'] = nameController.text;
                  recipeData['description'] = descriptionController.text;
                  recipeData['cuisine'] = cuisineController.text;
                  recipeData['cookTime'] = int.tryParse(cookTimeController.text) ?? 0;
                  recipeData['prepTime'] = int.tryParse(prepTimeController.text) ?? 0;
                  recipeData['course'] = courseController.text;
                  recipeData['servingAmount'] = int.tryParse(servingAmountController.text) ?? 0;
                  recipeData['spiceLevel'] = int.tryParse(spiceLevelController.text) ?? 1;

                  recipeData['ingredients'] = List.generate(
                    ingredientNameControllers.length,
                    (index) => {
                      'name': ingredientNameControllers[index].text,
                      'quantity': double.tryParse(ingredientQuantityControllers[index].text) ?? 1,
                      'unit': ingredientUnitControllers[index].text,
                    },
                  );

                  recipeData['methods'] = methodControllers
                      .map((controller) => controller.text)
                      .toList()
                      .join('<'); // Join the steps with '<'

                  recipeData['appliances'] = applianceControllers
                      .map((controller) => {'name': controller.text})
                      .toList();

                  Navigator.of(context).pop(); // Close the dialog

                  // Now, proceed to submit the recipe to the database
                  await addExtractedRecipeToDatabase(recipeData, _userId!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recipe added successfully!')),
                  );
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
