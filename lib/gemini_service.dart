import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '/screens/home_screen.dart';

Future<String> fetchContentBackpack() async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text('Write a story about a magic backpack.')];
  final response = await model.generateContent(content);

  return response.text ?? 'No response text';
}

Future<String> fetchContentHorse() async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text('Write a story about a horse.')];
  final response = await model.generateContent(content);

  return response.text ?? 'No response text';
}

Future<Map<String, dynamic>?> fetchRecipeDetails(String recipeId) async {
  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
  final headers = <String, String>{'Content-Type': 'application/json'};
  final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

  try {
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

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

Future<List<dynamic>?> fetchRecipesByCourse(String course) async {
  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
  final headers = <String, String>{'Content-Type': 'application/json'};
  final body = jsonEncode({'action': 'getRecipesByCourse', 'course': course});

  try {
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final dynamic fetchedRecipes = jsonDecode(response.body);

      // Check if the fetchedRecipes is a list
      if (fetchedRecipes is List<dynamic>) {
        return fetchedRecipes;
      } else {
        print('Expected a JSON array but got something else.');
        return null;
      }
    } else {
      print('Failed to load recipes: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('Error fetching recipes: $error');
    return null;
  }
}

Future<String> fetchUserDietaryConstraints(String userId) async {
  final url = Uri.parse(
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint');

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

Future<List<Map<String, String>>> fetchPantryList(String userId) async {
  try {
    final response = await http.post(
      Uri.parse(
          'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint'),
      body: jsonEncode({
        'action': 'getAvailableIngredients',
        'userId': userId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> pantryList = data['availableIngredients'];
      List<Map<String, String>> ingredients = pantryList.map((item) {
        return {
          'name': item['name'].toString(),
          'quantity': item['quantity'].toString(),
          'measurementUnit': item['measurmentunit'].toString()
        };
      }).toList();
      return ingredients;
    } else {
      print('Failed to fetch pantry list: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    print('Error fetching pantry list: $error');
    return [];
  }
}

Future<String> fetchMealPlannerRecipes(
    String userid,
    String gender,
    String weight,
    String weightUnit,
    String height,
    String heightUnit,
    int age,
    String activityLevel,
    String dietGoal,
    String mealFreq,
    String courses,
    String mealPlanName,
    BuildContext context // Add context to access the Scaffold/AlertDialog
    ) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  List<String> selectedCourses =
      courses.split(',').map((course) => course.trim()).toList();

  Map<String, dynamic> courseRecipes = {};

  for (String course in selectedCourses) {
    switch (course) {
      case 'Breakfast':
        courseRecipes['Breakfast'] = await fetchRecipesByCourse('Breakfast');
        break;
      case 'Main':
        courseRecipes['Main'] = await fetchRecipesByCourse('Main');
        break;
      case 'Lunch':
        courseRecipes['Main'] = await fetchRecipesByCourse('Main');
        break;
      case 'Dinner':
        courseRecipes['Main'] = await fetchRecipesByCourse('Main');
        break;
      case 'Appetizer':
        courseRecipes['Appetizer'] = await fetchRecipesByCourse('Appetizer');
        break;
      case 'Dessert':
        courseRecipes['Dessert'] = await fetchRecipesByCourse('Dessert');
        break;
      default:
        print('Unknown course: $course');
    }
  }

  final String dietaryConstraints = await fetchUserDietaryConstraints(userid);

  final initialPrompt = '''
  Create a meal planner named "$mealPlanName" for Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, and Sunday
  for the person with these details:
      - Gender: ${gender.replaceAll('"', r'\"')}
      - Weight: $weight $weightUnit
      - Height: $height $heightUnit
      - Age: $age
      - Activity Level: $activityLevel
      - Diet Goal: ${dietGoal.replaceAll('"', r'\"')}
      - Meal Frequency: $mealFreq
      - Dietary Constraints: $dietaryConstraints

  Here are the available recipes for the selected courses:
  ${courseRecipes.entries.map((entry) => '- ${entry.key} Recipes: ${jsonEncode(entry.value)}').join('\n')}
  ''';

  final format = """
  Please return the meal planner strictly in valid JSON format. Ensure the response follows this structure:

  {
    "Name": "$mealPlanName", 
    "Description": "\$description",
    "Meals": {
      "Monday": [
        { "recipeid": "\$recipeid1" },
        { "recipeid": "\$recipeid2" },
        { "recipeid": "\$recipeid3" }
      ],
      "Tuesday": [
        { "recipeid": "\$recipeid4" },
        { "recipeid": "\$recipeid5" },
        { "recipeid": "\$recipeid6" }
      ],
      "Wednesday": [...],
      "Thursday": [...],
      "Friday": [...],
      "Saturday": [...],
      "Sunday": [...]
    }
  }
Ensure the recipe IDs are provided as individual objects in the correct structure.
  Give valid JSON and don't add any explanations. The recipeids are NOT the names, rather uuid strings.
  For the description, please mention the user's activity level, diet goal and dietary constraints and 
  how the recipes were chosen considering these
  Return the JSON with **no extra text**, comments, or explanations. Ensure valid JSON (with double quotes 
  around keys and values) and all recipeids are UUID strings. **Check the output carefully for missing commas, 
  extra commas, or incorrect braces before returning it.**
""";

  final prompt = initialPrompt + format;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  if (response != null && response.text != null) {
    String jsonString = response.text!;
    //print("gem res1 $jsonString");

    // Clean up the JSON string
    try {
      jsonString = jsonString.replaceAll("'", '"'); // Ensure proper JSON format
      jsonString =
          jsonString.replaceAll(RegExp(r'\s+'), ' '); // Remove extra whitespace
      jsonString = jsonString.replaceAll(
          RegExp(r',(\s*[\]}])'), r'$1'); // Remove trailing commas

      // Remove unnecessary code block markers if present
      if (jsonString.startsWith('```json')) {
        jsonString =
            jsonString.substring(7).trim(); // Remove starting code block marker
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString
            .substring(0, jsonString.length - 3)
            .trim(); // Remove ending code block marker
      }

      // Try to parse JSON to ensure it's valid
      final jsonData = jsonDecode(jsonString);

      return jsonEncode(jsonData); // Return the formatted JSON string
    } catch (e) {
      _showErrorSnackbar(context, 'Something went wrong. Please try again.');
      print('Failed to parse JSON: $e');
      return 'Error parsing JSON';
    }
  } else {
    return 'No response text';
  }
}

void _showErrorSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<String> fetchIngredientSubstitutionRecipe(
    String recipeId, String substitute, String substitutedIngredient) async {
  // takes in a recipe id and substitute. finds a recipe using the substitute given
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // save the substitute
  // final substitute = "eggs";

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails =
      await fetchRecipeDetails(recipeId);
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
    ingredients =
        ingredientsData.split(',').map((item) => item.trim()).toList();
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
    {
      "name": "\$ingredient1",
      "quantity": "\$quantity1",
      "unit": "\$unit1"
    },
    {
      "name": "\$ingredient2",
      "quantity": "\$quantity2",
      "unit": "\$unit2"
    },
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

  final initialPrompt =
      """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  use this substitution $substitute instead of the $substitutedIngredient. 
  Make sure to adjust the quantities of the ingredients so the recipe is still accurate, 
  take into account the new ingredients liquidity, saltiness, sourness, sweetness, bitterness 
  as opposed to the previous ingredient and make sure the recipe will still create the same taste.
  Adjust the recipe keeping the same formatting with the substituted ingredient. 
  Make sure to adjust the quantities of the ingredients so the recipe is still accurate, 
  take into account the new ingredients liquidity, saltiness, sourness, sweetness, bitterness 
  as opposed to the previous ingredient and make sure the recipe will still create the same taste.
  Please make any fractions into decimal values. Before you give me a response take your time and think really hard, 
  and double check the response and formatting of the output before sending it""";

  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    //print(jsonString);

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
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

Future<String> fetchIngredientSubstitutions(
    String recipeId, String substitute, String userId) async {
  // takes in the recipe id and substitute. This is the ingredient for which we want to find
  // substitutes for
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails =
      await fetchRecipeDetails(recipeId);
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
    ingredients =
        ingredientsData.split(',').map((item) => item.trim()).toList();
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
  final formatting =
      """Return the result in JSON format with the following structure:
  {
    "substitute1": "value1",
    "substitute2": "value2",
    "substitute3": "value3",
    "substitute4": "value4",
    "substitute5": "value5"
  }
  Just list the substitute ingredients without explanation and make sure the output is valid JSON.""";

  final initialPrompt =
      """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  suggest 5 substitutions for $substitute considering these dietary constraints: $dietaryConstraints. Only give the ingredient names.""";

  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    //print(jsonString);

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
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
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails =
      await fetchRecipeDetails(recipeId);
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
    ingredients =
        ingredientsData.split(',').map((item) => item.trim()).toList();
  }

  // Handle steps
  final stepsData = recipeDetails['steps'];
  if (stepsData is List) {
    steps = stepsData.map((item) => item.toString()).toList();
  } else if (stepsData is String) {
    // If the data is a single string, split it by newlines or other delimiters
    steps = stepsData.split('\n').map((item) => item.trim()).toList();
  }

  final prompt =
      """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
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

    //print(jsonString);

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
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
  const String apiKey = String.fromEnvironment('API_KEY') ;
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails =
      await fetchRecipeDetails(recipeId);
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
    ingredients =
        ingredientsData.split(',').map((item) => item.trim()).toList();
  }

  // Handle steps
  final stepsData = recipeDetails['steps'];
  if (stepsData is List) {
    steps = stepsData.map((item) => item.toString()).toList();
  } else if (stepsData is String) {
    // If the data is a single string, split it by newlines or other delimiters
    steps = stepsData.split('\n').map((item) => item.trim()).toList();
  }

  final prompt =
      """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
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

    //print(jsonString);

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
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

// gets the user's pantry list and creates a recipe based off of the ingredients
Future<String> fetchRecipeFromPantryIngredients(String userId) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Step 1: Fetch pantry ingredients using fetchPantryList
  List<Map<String, String>> pantryList = await fetchPantryList(userId);

  if (pantryList.isEmpty) {
    return 'No pantry ingredients available';
  }

  // Step 2: Compare pantry ingredients with available recipes to find matches
  final prompt = """Based on the following pantry ingredients:
  ${pantryList.map((item) => '${item['name']} (${item['quantity']} ${item['measurementUnit']})').join(', ')},
  suggest a recipe that can be made using these ingredients. 
  Return the result in JSON format with the following structure:
  {
    "title": "value",
    "ingredients": ["ingredient1", "ingredient2", ...],
    "steps": ["step1", "step2", ...],
    "cuisine": "value",
    "servings": "value",
    "description": "value"
  }
  Just provide the JSON without explanation and make sure the output is valid JSON.""";

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  if (response != null && response.text != null) {
    String jsonString = response.text!;
    //print(jsonString);

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
    }

    // Join the lines back together
    jsonString = lines.join('\n');

    // Optionally, parse the JSON string to a Map to verify it's a valid JSON
    try {
      //final jsonMap = jsonDecode(jsonString);
      //print('Parsed JSON: $jsonMap');
    } catch (e) {
      print('Failed to parse JSON: $e');
      return 'Failed to parse JSON';
    }

    return jsonString;
  } else {
    return 'No response text';
  }
}

// only 1 dietary constraint
Future<String> fetchDietaryConstraintRecipe(
    String dietaryConstraint, String recipeId) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails =
      await fetchRecipeDetails(recipeId);
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
    ingredients =
        ingredientsData.split(',').map((item) => item.trim()).toList();
  }

  // Handle steps
  final stepsData = recipeDetails['steps'];
  if (stepsData is List) {
    steps = stepsData.map((item) => item.toString()).toList();
  } else if (stepsData is String) {
    // If the data is a single string, split it by newlines or other delimiters
    steps = stepsData.split('\n').map((item) => item.trim()).toList();
  }

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

  final initialPrompt =
      """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  adjust the recipe to be suitable for this dietary constraint $dietaryConstraint. 
  Please make any fractions into decimal values.""";

  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    //print(jsonString);

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
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

Future<List<String>> fetchAllowedAppliances() async {
  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'action': 'getAllAppliances',
      }),
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> appliances = jsonDecode(response.body);
        //print(response.body);
        return appliances
            .map((appliance) => appliance['name'] as String)
            .toList();
      } catch (e) {
        print('Error parsing JSON: $e');
        print('Response body: ${response.body}');
        return [];
      }
    } else {
      print('Error fetching allowed appliances: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Exception during fetch: $e');
    return [];
  }
}

///extract json data for recipe
Future<Map<String, dynamic>?> extractRecipeData(
    String pastedText, String selectedImage) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    print('Error: API_KEY environment variable is missing.');
    return null;
  }

  //print(" image: $selectedImage");

  final allowedAppliances = await fetchAllowedAppliances();

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final prompt = """
Extract the following recipe information from the text below and return it in JSON format with this structure:

{
  "name": "\$name",
  "description": "\$description",
  "cuisine": "\$cuisine",
  "cookTime": "\$cookingTime (in minutes only put the number)",
  "prepTime": "\$prepTime (in minutes only put the number))",
  "course": "\$course (Breakfast,Main,Dessert, Appetizer)",
  "servingAmount": "\$servingAmount",
  "spiceLevel": "\$spiceLevel (None=1, Mild=2, Medium=3, Hot=4, Extra Hot=5 default to 1 if nothing is provided)",
  "ingredients": [
    {
      "name": "\$ingredient1",
      "quantity": "\$quantity1",
      "unit": "\$unit1"
    },
    {
      "name": "\$ingredient2",
      "quantity": "\$quantity2",
      "unit": "\$unit2"
    },
    ...
  ],
  "methods": [
    "Step 1",
    "Step 2",
    "Step 3",
    ...
  ],
  "appliances": [
    { "name": "\$appliance1" },
    { "name": "\$appliance2" },
    ...
  ],
  'photo': "$selectedImage"
}

**Important Conditions:**

1. **Allowed Appliances:** Only include the following appliances. Do not add any appliances that are not in this list: ${allowedAppliances.join(', ')}. If an appliance is mentioned that is not in this list, exclude it from the JSON output.
2. **Measurement Conversion and Specificity:** All measurements must be numeric and specific. For example, "1/4 cups" should be converted to "0.25 cups", and "to taste" or "as needed" should not be used. Convert them to specific measurements like grams, tablespoons, etc., based on common usage.
3. **Exclude Incomplete Information:** If any ingredient lacks a specific quantity or unit, exclude it from the list the quantity and unit of an ingredient can never be null. each word in the ingredient name must start with a capital letter and the unit must also start with a capital letter

Text:
$pastedText
  """;

  // send prompt
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  if (response != null && response.text != null) {
    String jsonString = response.text!;

    // fix json
    jsonString =
        jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      final Map<String, dynamic> recipeData = jsonDecode(jsonString);

      if (recipeData.containsKey('methods')) {
        recipeData['methods'] =
            (recipeData['methods'] as List<dynamic>).map((step) {
          return step.toString();
        }).join('<'); //format steps
      }

      //check that each ingredient has a unit and quantity, if not add default
      if (recipeData.containsKey('ingredients')) {
        List<dynamic> ingredients = recipeData['ingredients'];
        for (var ingredient in ingredients) {
          //check if the unit has a value
          if (ingredient['unit'] == null ||
              ingredient['unit'].isEmpty ||
              ingredient['unit'].toLowerCase() == "null") {
            ingredient['unit'] = 'units';
          }

          //check quantity has a value
          if (ingredient['quantity'] == null ||
              ingredient['quantity'].toString().isEmpty ||
              ingredient['quantity'].toString().toLowerCase() == "null") {
            ingredient['quantity'] = 1;
          }
        }
        recipeData['ingredients'] = ingredients;
      }

      //remove any appliances not in the specified list
      if (recipeData.containsKey('appliances')) {
        List<dynamic> appliances = recipeData['appliances'];
        appliances = appliances.where((appliance) {
          return allowedAppliances.contains(appliance['name']);
        }).toList();
        recipeData['appliances'] = appliances;
      }

      //print("rec data: $recipeData");
      return recipeData;
    } catch (e) {
      print('Error parsing JSON response: $e');
      return null;
    }
  } else {
    print('Error: No response from Gemini.');
    return null;
  }
}

/// add pasted rec to db
Future<void> addExtractedRecipeToDatabase(
    Map<String, dynamic> recipeData, String userId) async {
  final url =
      'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
  final headers = <String, String>{'Content-Type': 'application/json'};

  final payload = {
    'action': 'addRecipe',
    'userId': userId,
    'recipeData': recipeData,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      //print('Recipe added successfully!');

      // Fetch the recipe ID using the recipe name
      final recipeIdResponse = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'action': 'getRecipeId',
          'recipeData': {
            'name': recipeData['name'],
          },
        }),
      );

      if (recipeIdResponse.statusCode == 200) {
        final recipeId = jsonDecode(recipeIdResponse.body)['recipeId'];

        // Fetch and add keywords
        final keywordsJsonString = await fetchKeywords(recipeId);
        Map<String, String> keywords;
        try {
          keywords = Map<String, String>.from(jsonDecode(keywordsJsonString));
        } catch (e) {
          print('Failed to parse keywords: $e');
          return;
        }
        final keywordsString = keywords.values.join(',');

        final addKeywordsResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            'action': 'addRecipeKeywords',
            'recipeid': recipeId,
            'keywords': keywordsString,
          }),
        );

        if (addKeywordsResponse.statusCode == 200) {
          //print('Keywords added successfully');
        } else {
          print('Failed to add keywords');
        }

        // Fetch and add dietary constraints
        final dietaryConstraintsJsonString =
            await fetchDietaryConstraints(recipeId);
        Map<String, dynamic> dietaryConstraints;
        try {
          dietaryConstraints = jsonDecode(dietaryConstraintsJsonString);
        } catch (e) {
          print('Failed to parse dietary constraints: $e');
          return;
        }

        // Filter dietary constraints that are "yes" or "true"
        final filteredConstraints = dietaryConstraints.entries
            .where((entry) =>
                entry.value.toLowerCase() == 'yes' ||
                entry.value.toLowerCase() == 'true')
            .map((entry) => entry.key)
            .toList();

        final constraintsString = filteredConstraints.join(',');

        final addDietaryConstraintsResponse = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            'action': 'addRecipeDietaryConstraints',
            'recipeid': recipeId,
            'dietaryConstraints': constraintsString,
          }),
        );

        if (addDietaryConstraintsResponse.statusCode == 200) {
          //print('Dietary constraints added successfully');
        } else {
          print('Failed to add dietary constraints');
        }
      } else {
        print('Failed to retrieve recipe ID');
      }
    } else {
      print('Failed to add recipe: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    //print('Error adding recipe to database: $e');
  }
}

Future<List<String>> identifyIngredientFromReceipt(String items) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return ['No API_KEY environment variable'];
  }

  final formatting = """Return the items in the following JSON format:
  {
  "items": [
    {
      "name": "Item Name",
      "ingredient": "Ingredient Name"
    },
    {
      "name": "Item Name",
      "ingredient": "Ingredient Name"
    }
  ]
}
  They should all be Strings.""";

  final initialPrompt =
      """For these items: $items; remove all non-edible items and all non human food 
  and then identify what food stuff the remaining items are. Be specific, like mince should should be specified as such i.e Beef Mince.""";

  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    //print(jsonString);

    // Correct the JSON format by replacing single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Remove markdown syntax if present
    jsonString = jsonString
        .replaceAll(RegExp(r'```(json)?\s*'), '')
        .replaceAll(RegExp(r'\s*```'), '');

    // Parse the JSON string to a Map to verify it's valid JSON
    try {
      final jsonMap = jsonDecode(jsonString);
      final itemsList = (jsonMap['items'] as List<dynamic>)
          .map((item) =>
              'Item: ${item['name']}, Ingredient: ${item['ingredient']}')
          .toList();
      return itemsList;
    } catch (e) {
      print('Failed to parse JSON: $e');
      return [];
    }
  } else {
    return ['No response text'];
  }
}

Future<String> findBestMatchingIngredient(
    String identifiedIngredient, List<String> dbIngredients) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Create the prompt for Gemini
  final prompt =
      """Compare the identified ingredient "$identifiedIngredient" to this list of ingredients from the database: ${dbIngredients.join(', ')}.
  Return the most similar ingredient from the list - based on the name of the identified ingredient - without explanation.""";

  // Initialize the model with your API key
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  if (response != null && response.text != null) {
    return response.text!.trim(); // The most similar ingredient
  } else {
    return 'No response';
  }
}

// all dietary constraints
Future<String> fetchDietaryConstraintsRecipe(
    String userId, String recipeId) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return 'No API_KEY environment variable';
  }

  // Fetch recipe details
  final Map<String, dynamic>? recipeDetails =
      await fetchRecipeDetails(recipeId);
  if (recipeDetails == null) {
    return 'Failed to fetch recipe details';
  }

  // fetch user's dietary constraints
  //print("user id in gem: $userId");
  final String dietaryConstraints = await fetchUserDietaryConstraints(userId);
  //print("dc: $dietaryConstraints");

  // Ensure the data is parsed correctly
  List<String> ingredients = [];
  List<String> steps = [];

  // Handle ingredients
  final ingredientsData = recipeDetails['ingredients'];
  if (ingredientsData is List) {
    ingredients = ingredientsData.map((item) => item.toString()).toList();
  } else if (ingredientsData is String) {
    // If the data is a single string, split it by commas or other delimiters
    ingredients =
        ingredientsData.split(',').map((item) => item.trim()).toList();
  }

  // Handle steps
  final stepsData = recipeDetails['steps'];
  if (stepsData is List) {
    steps = stepsData.map((item) => item.toString()).toList();
  } else if (stepsData is String) {
    // If the data is a single string, split it by newlines or other delimiters
    steps = stepsData.split('\n').map((item) => item.trim()).toList();
  }

  final formatting =
      """Return the recipe in JSON using the following structure the ingredients must be in the specified structure:
  {
    "title": "\$title",
    "ingredients": [
    {
      "name": "\$ingredient1",
      "quantity": "\$quantity1",
      "unit": "\$unit1"
    },
    {
      "name": "\$ingredient2",
      "quantity": "\$quantity2",
      "unit": "\$unit2"
    },
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

  final initialPrompt =
      """For the recipe titled "${recipeDetails['name'] ?? 'Unknown'}", 
  with ingredients ${ingredients.join(', ')}, and steps ${steps.join(' ')}, 
  adjust the recipe to be suitable for these dietary constraints: $dietaryConstraints. 
  Please make any fractions into decimal values.
  Replace each non-compliant ingredient with a specific and commonly available alternative that meets the dietary requirements. 
  Ensure that all substitutions are practical and commonly used in cooking.""";

  final finalPrompt = initialPrompt + formatting;

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final content = [Content.text(finalPrompt)];
  final response = await model.generateContent(content);

  // Ensure response is not null and print the text content
  if (response != null && response.text != null) {
    String jsonString = response.text!;

    //print("Altered recipe in gem:  $jsonString");

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
      print(
          "The JSON string does not have enough lines to remove the first and last lines.");
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

Future<List<String>> validateRecipe(
    String name, String description, List<String> steps) async {
  const String apiKey = String.fromEnvironment('API_KEY');
  if (apiKey.isEmpty) {
    return ['No API_KEY environment variable'];
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  final prompt = """
Validate the following recipe data:

- Name: "$name"
- Description: "$description"
- Steps: ${steps.join(', ')}

Ensure that:
- The name, description, and steps are relevant to cooking.
- They do not contain inappropriate words or phrases.
- Do not comment if there are grammar, punctuation or spelling errors
-Description can be anything as long as it does not contain inappropriate words or phrases.
-Steps do not have to be extreamly precise or complete as long as they do not contain inappropriate words or phrases and are cooking related

If there are any issues, return a simple list of validation errors like this:
[
  "Error 1: The name contains inappropriate words.",
  "Error 2: Step 2 is not relevant to cooking."
]

Otherwise, return an empty list if everything is valid.
  """;

  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  if (response != null && response.text != null) {
    String responseText = response.text!;

    // Clean up the response
    responseText = responseText.trim();

    // Ensure the response is a valid JSON array by removing any unwanted text
    responseText = responseText.replaceAll(
        RegExp(r'[^\[]*\['), '['); // Remove text before the array
    responseText = responseText.replaceAll(
        RegExp(r'\][^\]]*$'), ']'); // Remove text after the array

    // Attempt to parse the cleaned-up JSON response
    try {
      List<String> errors = List<String>.from(jsonDecode(responseText));
      return errors;
    } catch (e) {
      print('Error parsing validation response: $e');
      return ['Failed to parse validation response'];
    }
  } else {
    return ['No response from Gemini'];
  }
}
