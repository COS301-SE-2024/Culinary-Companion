import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '/screens/home_screen.dart'; 


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

Future<Map<String, dynamic>?> fetchRecipeDetails(String recipeId) async {
  final url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
  final headers = <String, String>{'Content-Type': 'application/json'};
  final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> fetchedRecipe = jsonDecode(response.body);
      return fetchedRecipe;
    } else {
      print('Failed to load recipe details: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching recipe details: $error');
    return null;
  }
}

Future<String> fetchIngredientSubstitution(String recipeId) async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // save the substitute
  final substitute = "eggs";

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails = await fetchRecipeDetails(recipeId);
  if (recipeDetails == null) {
    return 'Failed to fetch recipe details';
  }

  // Ensure the data is parsed correctly
  List<String> ingredients = [];
  List<String> steps = [];

  // Handle ingredients
  final ingredientsData = recipeDetails['ingredients'];
  if (ingredientsData is List) {
    ingredients = ingredientsData.map((item) => item.toString()).toList();
  } else if (ingredientsData is String) {
    // If the data is a single string, split it by commas or other delimiters
    ingredients = ingredientsData.split(',').map((item) => item.trim()).toList();
  }

  // Handle steps
  final stepsData = recipeDetails['steps'];
  if (stepsData is List) {
    steps = stepsData.map((item) => item.toString()).toList();
  } else if (stepsData is String) {
    // If the data is a single string, split it by newlines or other delimiters
    steps = stepsData.split('\n').map((item) => item.trim()).toList();
  }

  // Construct the prompt using the fetched recipe details
  final formatting = """Return the recipe in JSON using the following structure:
  {
    "title": "\$recipeTitle",
    "ingredients": \$ingredients,
    "steps": \$steps,
    "cuisine": "\$cuisine",
    "description": "\$description",
    "servings": "\$servings"
  }
  title, description, cuisine and servings should be of type String.
  ingredients and steps should be of type List<String>.""";

  final initialPrompt = """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  suggest a substitution for $substitute. 
  Adjust the recipe keeping the same formatting with the substituted ingredient.""";
  
  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;
    
    // Correct the JSON format by replacing single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Split the JSON string by lines
    List<String> lines = jsonString.split('\n');
    
    // Check if there are more than two lines before removing the first and last lines
    if (lines.length > 2) {
      lines.removeAt(0); // Remove the first line
      lines.removeAt(lines.length - 1); // Remove blank line
      lines.removeAt(lines.length - 1); // Remove the last line
    } else {
      print("The JSON string does not have enough lines to remove the first and last lines.");
    }
    
    // Join the lines back together
    jsonString = lines.join('\n');
    
    // Optionally, parse the JSON string to a Map to verify it's a valid JSON
    try {
      final jsonMap = jsonDecode(jsonString);
      print('Parsed JSON: $jsonMap');
    } catch (e) {
      print('Failed to parse JSON: $e');
    }

    return jsonString;
  } else {
    return 'No response text';
  }
}
