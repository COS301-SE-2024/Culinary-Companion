import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> with SingleTickerProviderStateMixin {
  final List<String> _ingredients = [];
  final List<String> _methods = [];
  late TabController _tabController;

  void _addIngredientField() {
    setState(() {
      _ingredients.add('');
    });
  }

  void _addMethodField() {
    setState(() {
      _methods.add('');
    });
  }

  void _submitRecipe() {
    print('Ingredients: ${_ingredients.join(', ')}');
    print('Methods: ${_methods.join(', ')}');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Culinary Companion'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Scan Recipe'),
            Tab(text: 'Form'),
            Tab(text: 'Text Input'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scan Recipe Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 100),
                SizedBox(height: 16),
                Text(
                  'Drag & Drop Recipe Here',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Browse Files'),
                ),
              ],
            ),
          ),
          // Form Screen
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload Recipe:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Add ingredients:', style: TextStyle(fontSize: 16)),
                  ..._ingredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            int index = _ingredients.indexOf(ingredient);
                            if (index >= 0) {
                              _ingredients[index] = value;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Ingredient',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }).toList(),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: _addIngredientField,
                  ),
                  SizedBox(height: 20),
                  Text('Add methods:', style: TextStyle(fontSize: 16)),
                  ..._methods.map((method) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            int index = _methods.indexOf(method);
                            if (index >= 0) {
                              _methods[index] = value;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Method',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }).toList(),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: _addMethodField,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitRecipe,
                      child: Text('Add Recipe'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Text Input Screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.text_fields, size: 100),
                SizedBox(height: 16),
                Text(
                  'Paste Text',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Analyze Recipe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}