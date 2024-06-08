import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/recipe_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
  }

  Future<void> fetchAllRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getAllRecipes'});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);
        setState(() {
          print(fetchedRecipes);
          recipes = List<Map<String, dynamic>>.from(fetchedRecipes);
        });
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  double itemWidth = 276;
                  double itemHeight = 320;
                  double aspectRatio = itemWidth / itemHeight;

                  // Calculate relative spacing based on screen width
                  double crossAxisSpacing = width * 0.01; // 5% of screen width
                  double mainAxisSpacing = width * 0.02; // 6% of screen width

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // Set the number of columns to 3
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      // Split keywords string into a list of keywords
                      List<String> keywords =
                          (recipes[index]['keywords'] as String?)?.split(', ') ?? [];

                      return RecipeCard(
                        name: recipes[index]['name'] ?? '', // Use an empty string if name is null
                        description: recipes[index]['description'] ?? '',
                        imagePath: recipes[index]['photo'] ?? 'assets/pfp.jpg',
                        prepTime: recipes[index]['preptime'] ?? 0, // Use 0 if prepTime is null
                        cookTime: recipes[index]['cooktime'] ?? 0,
                        cuisine: recipes[index]['cuisine'] ?? '',
                        spiceLevel: recipes[index]['spicelevel'] ?? 0,
                        course: recipes[index]['course'] ?? '',
                        servings: recipes[index]['servings'] ?? 0,
                        keyWords: keywords,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
