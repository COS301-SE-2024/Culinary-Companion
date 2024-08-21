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

Future<String> fetchUserDietaryConstraints(String userId) async {
  final url = Uri.parse('https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint');

  try {
    // Send a POST request to fetch dietary constraints for the user
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'getUserDietaryConstraints', 
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Check if the response contains the constraints
      if (responseData.containsKey('constraints')) {
        return responseData['constraints'];
      } else {
        return 'No dietary constraints found';
      }
    } else {
      return 'Failed to fetch dietary constraints: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error fetching dietary constraints: $e';
  }
}

Future<String> fetchIngredientSubstitutionRecipe(String recipeId, String substitute, String substitutedIngredient) async {
  // takes in a recipe id and substitute. finds a recipe using the substitute given
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // save the substitute
  // final substitute = "eggs";

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
  // final formatting = """Return the recipe in JSON using the following structure:
  // {
  //   "title": "\$recipeTitle",
  //   "ingredients": \$ingredients,
  //   "steps": \$steps,
  //   "cuisine": "\$cuisine",
  //   "description": "\$description",
  //   "servings": "\$servings"
  // }
  // title, description, cuisine and servings should be of type String.
  // ingredients and steps should be of type List<String>.""";
   final formatting = """Return the recipe in JSON using the following structure:
  {
    "title": "\$title",
    "ingredients": [
      "ingredient1 (quantity)",
      "ingredient2 (quantity)",
      ...
    ],
    "steps": [
      "Step 1",
      "Step 2",
      ...
    ],
    "cuisine": "\$cuisine",
    "description": "\$description",
    "servings": "\$servings"
  }
  They should all be Strings.""";

  final initialPrompt = """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  use this substitution $substitute instead of the $substitutedIngredient. 
  Adjust the recipe keeping the same formatting with the substituted ingredient. Please make any fractions into decimal values.""";
  
  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    print(jsonString);
    
    // Correct the JSON format by replacing single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Split the JSON string by lines
    List<String> lines = jsonString.split('\n');

    // Check if there are more than two lines before removing the first and last lines
    if (lines.length > 2) {
      // Check if the first line is "``` json"
      if (lines[0] == "```json") {
        lines.removeAt(0); // Remove the first line
      }

      // Check if the last line is a blank line and remove it
      if (lines.last.isEmpty) {
        lines.removeAt(lines.length - 1); // Remove the blank line
      }

      // Check if the new last line is "```" and remove it
      if (lines.last == "```") {
        lines.removeAt(lines.length - 1); // Remove the last line
      }
    } else {
      print("The JSON string does not have enough lines to remove the first and last lines.");
    }
    
    // Join the lines back together
    jsonString = lines.join('\n');
    
    // Optionally, parse the JSON string to a Map to verify it's a valid JSON
    try {
      //final jsonMap = jsonDecode(jsonString);
      //print('Parsed JSON: $jsonMap');
    } catch (e) {
      print('Failed to parse JSON: $e');
    }

    return jsonString;
  } else {
    return 'No response text';
  }
}

Future<String> fetchIngredientSubstitutions(String recipeId, String substitute, String userId) async {
  // takes in the recipe id and substitute. This is the ingredient for which we want to find
  // substitutes for 
  // edit: take in user id to retrieve user's dietary constraints
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails = await fetchRecipeDetails(recipeId);
  if (recipeDetails == null) {
    return 'Failed to fetch recipe details';
  }

  // fetch user's dietary constraints
  final String dietaryConstraints = await fetchUserDietaryConstraints(userId);

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
  final formatting = """Return the result in JSON format with the following structure:
  {
    "substitute1": "value1",
    "substitute2": "value2",
    "substitute3": "value3",
    "substitute4": "value4",
    "substitute5": "value5"
  }
  Just list the substitute ingredients without explanation and make sure the output is valid JSON.""";

  final initialPrompt = """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  suggest 5 substitutions for $substitute considering these dietary constraints: $dietaryConstraints. Only give the ingredient names.""";
  
  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    print(jsonString);
    
    // Correct the JSON format by replacing single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Split the JSON string by lines
    List<String> lines = jsonString.split('\n');

    // Check if there are more than two lines before removing the first and last lines
    if (lines.length > 2) {
      // Check if the first line is "``` json"
      if (lines[0] == "```json") {
        lines.removeAt(0); // Remove the first line
      }

      // Check if the last line is a blank line and remove it
      if (lines.last.isEmpty) {
        lines.removeAt(lines.length - 1); // Remove the blank line
      }

      // Check if the new last line is "```" and remove it
      if (lines.last == "```") {
        lines.removeAt(lines.length - 1); // Remove the last line
      }
    } else {
      print("The JSON string does not have enough lines to remove the first and last lines.");
    }
    
    // Join the lines back together
    jsonString = lines.join('\n');
    
    // Optionally, parse the JSON string to a Map to verify it's a valid JSON
    try {
      //final jsonMap = jsonDecode(jsonString);
      //print('Parsed JSON: $jsonMap');
    } catch (e) {
      print('Failed to parse JSON: $e');
    }

    return jsonString;
  } else {
    return 'No response text';
  }
}

Future<String> fetchKeywords(String recipeId) async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

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

  final prompt = """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  extract the 5 most relevant keywords that describe the dish, including ingredients and flavours. 
  Return the result in JSON format with the following structure:
  {
    "keyword1": "value1",
    "keyword2": "value2",
    "keyword3": "value3",
    "keyword4": "value4",
    "keyword5": "value5"
  }
  Just list the keywords without explanation and make sure the output is valid JSON.""";
  
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  if (response != null && response.text != null) {
    String jsonString = response.text!;

    print(jsonString);
    
    // Correct the JSON format by replacing single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Split the JSON string by lines
    List<String> lines = jsonString.split('\n');
    
    // Check if there are more than two lines before removing the first and last lines
    if (lines.length > 2) {
      // Check if the first line is "``` json"
      if (lines[0] == "```json") {
        lines.removeAt(0); // Remove the first line
      }

      // Check if the last line is a blank line and remove it
      if (lines.last.isEmpty) {
        lines.removeAt(lines.length - 1); // Remove the blank line
      }

      // Check if the new last line is "```" and remove it
      if (lines.last == "```") {
        lines.removeAt(lines.length - 1); // Remove the last line
      }
    } else {
      print("The JSON string does not have enough lines to remove the first and last lines.");
    }
    
    // Join the lines back together
    jsonString = lines.join('\n');
    
    // Optionally, parse the JSON string to a Map to verify it's a valid JSON
    try {
      //final jsonMap = jsonDecode(jsonString);
      //print('Parsed JSON: $jsonMap');
    } catch (e) {
      print('Failed to parse JSON: $e');
    }

    return jsonString;
  } else {
    return 'No response text';
  }
}


Future<String> fetchDietaryConstraints(String recipeId) async {
  final apiKey = dotenv.env['API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

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

  final prompt = """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
    with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
    analyze the recipe and identify which of the following dietary constraints the recipe belongs to:
    Vegan, Gluten Free, Dairy Free, Nut Free, Low Carb, Low Fat, Low Sodium, Paleo, Keto, Whole30, Pescatarian, 
    Lacto Vegetarian, Ovo Vegetarian, Lacto-Ovo Vegetarian, Halal, Kosher, FODMAP, Sugar Free, Low Sugar, Organic, 
    Raw Food, Diabetic, Low Cholesterol, Soy Free, Corn Free, Nightshade Free, Shellfish Free, Egg Free, Peanut Free, 
    MSG Free, Artificial Colour Free, Artificial Flavour Free, Artificial Preservative Free, Non-GMO, None.
    Just list the categories in JSON format with the following structure:
    {
      "constraint1": "value1",
      "constraint2": "value2",
      "constraint3": "value3",
      "constraint4": "value4",
      "constraint5": "value5"
    }
    Ensure that the response is valid JSON and contains only the JSON structure without any additional text or explanation.""";

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

//   if (response != null && response.text != null) {
//     String responseText = response.text!;

//     // Debugging: Print raw response text
//     print("Raw response text:");
//     print(responseText);

//     // Clean the response text
//     responseText = responseText.trim();

//     // Ensure valid JSON format
//     responseText = responseText.replaceAll(RegExp(r'[^\{]*\{'), '{'); // Remove leading text before the JSON
//     responseText = responseText.replaceAll(RegExp(r'\}[^\}]*$'), '}'); // Remove trailing text after the JSON

//     // Debugging: Print cleaned response text
//     print("Cleaned response text:");
//     print(responseText);

//     // Attempt to parse the JSON response
//     try {
//       final Map<String, dynamic> jsonResponse = jsonDecode(responseText);
//       // Convert JSON to a pretty-printed string for better readability
//       String prettyJsonString = JsonEncoder.withIndent('  ').convert(jsonResponse);
//       print('Parsed JSON: $prettyJsonString');
//       return prettyJsonString;
//     } catch (e) {
//       print('Failed to parse JSON: $e');
//       return 'Failed to parse JSON response';
//     }
//   } else {
//     return 'No response text';
//   }
// }
if (response != null && response.text != null) {
    String jsonString = response.text!;

    print(jsonString);
    
    // Correct the JSON format by replacing single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Split the JSON string by lines
    List<String> lines = jsonString.split('\n');
    
    // Check if there are more than two lines before removing the first and last lines
    if (lines.length > 2) {
      // Check if the first line is "``` json"
      if (lines[0] == "```json") {
        lines.removeAt(0); // Remove the first line
      }

      // Check if the last line is a blank line and remove it
      if (lines.last.isEmpty) {
        lines.removeAt(lines.length - 1); // Remove the blank line
      }

      // Check if the new last line is "```" and remove it
      if (lines.last == "```") {
        lines.removeAt(lines.length - 1); // Remove the last line
      }
    } else {
      print("The JSON string does not have enough lines to remove the first and last lines.");
    }
    
    // Join the lines back together
    jsonString = lines.join('\n');
    
    // Optionally, parse the JSON string to a Map to verify it's a valid JSON
    try {
      //final jsonMap = jsonDecode(jsonString);
      //print('Parsed JSON: $jsonMap');
    } catch (e) {
      print('Failed to parse JSON: $e');
    }

    return jsonString;
  } else {
    return 'No response text';
  }
}

