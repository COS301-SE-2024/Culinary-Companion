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

// Future<String> fetchFormattedRecipe(String recipeText) async {
//   await dotenv.load();
//   final apiKey = dotenv.env['API_KEY'] ?? '';
//   if (apiKey.isEmpty) {
//     return 'No API_KEY environment variable';
//   }
//   //print('here1');
//   final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
//   final content = [
//     Content.text('Format the following recipe for database insertion, including fields: name, description, cookTime, prepTime, servingAmount, cuisine, course, spiceLevel, ingredients (name, quantity, unit), methods, appliances (name). Here is the recipe: $recipeText')
//   ];
//   final response = await model.generateContent(content);
 
//   print('$response');
//   return response.text ?? 'No response text';
  
// }