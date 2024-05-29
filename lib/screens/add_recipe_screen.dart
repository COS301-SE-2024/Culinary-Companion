import 'package:flutter/material.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final List<String> _ingredients = [];
  final List<String> _methods = [];

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add ingredients:', style: TextStyle(fontSize: 18)),
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
                    decoration: InputDecoration(hintText: 'Ingredient'),
                  ),
                );
              }).toList(),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _addIngredientField,
              ),
              SizedBox(height: 20),
              Text('Add methods:', style: TextStyle(fontSize: 18)),
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
                    decoration: InputDecoration(hintText: 'Method'),
                  ),
                );
              }).toList(),
              IconButton(
                icon: Icon(Icons.add),
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
    );
  }
}
