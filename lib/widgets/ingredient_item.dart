import 'package:flutter/material.dart';

class IngredientItem extends StatelessWidget {
  final String ingredient;

  IngredientItem({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ingredient),
    );
  }
}