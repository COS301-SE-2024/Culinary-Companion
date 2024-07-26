// import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> fetchContentBackpack() async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text('Write a story about a magic backpack.')];
  final response = await model.generateContent(content);

  return response.text ?? 'No response text';
}


Future<String> fetchContentHorse() async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text('Write a story about a horse.')];
  final response = await model.generateContent(content);

  return response.text ?? 'No response text';
}

Future<String> fetchIngredientSubstitution() async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  final formatting = """Return the recipe in JSON using the following structure:
  {
    'title': \$recipeTitle,
    'ingredients': \$ingredients,
    'steps': \$steps,
    'cuisine': \$cuisine,
    'description': \$description,
    'servings': \$servings,
  }
  title, description, cuisine and servings should be of type String.
  ingredients and steps should be of type List<String>.""";

  final initialPrompt = """For this Simple Brownie Recipe, with ingredients 2 cups white sugar, 1 1/2 cups all-purpose flour, 
  1 cup butter (melted), 4 eggs, 1/2 cup cocoa powder, 1 teaspoon vanilla extract, 1/2 teaspoon baking powder, 
  1/2 teaspoon salt, 1/2 cup chopped walnuts and steps 1.Preheat the oven to 350 degrees F (175 degrees C). 
  Grease a 9x13-inch pan. 2.Mix sugar, flour, melted butter, eggs, cocoa powder, vanilla, baking powder, 
  and salt in a large bowl until combined. Fold in chopped walnuts. Spread the batter into the prepared pan. 
  3.Bake in the preheated oven until top is dry and edges have started to pull away from the sides of the pan, 
  about 20 to 30 minutes; cool before slicing into squares. Suggest a substitution for eggs. 
  Adjust the recipe keeping the same formatting with the substituted ingredient.""";
  
  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  print(response);
  return response.text ?? 'No response text';

  // // Ensure response is not null and print the text content
  // if (response != null && response.text != null) {
  //   final jsonString = response.text!;
  //   print(jsonString);
    
  //   // Optionally, parse the JSON string to a Map to verify it's a valid JSON
  //   try {
  //     final jsonMap = jsonDecode(jsonString);
  //     print('Parsed JSON: $jsonMap');
  //   } catch (e) {
  //     print('Failed to parse JSON: $e');
  //   }

  //   return jsonString;
  // } else {
  //   return 'No response text';
  // }
}