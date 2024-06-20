import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/recipe_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userId;
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> recipes = []; //List to store user's recipes

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

///////////load the user id/////////////
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      print('Login successful: $_userId');
    });
    if (_userId != null) {
      await _fetchUserDetails();
      await fetchRecipes();//Fetch user recipes after fetching user details
      //print('hereeee 2');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User ID not found';
      });
    }
  }

///////////fetch the users profile details/////////
  Future<void> _fetchUserDetails() async {
    if (_userId == null) return;

    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'getUserDetails',
          'userId': _userId,
        }),
      );

      //print(response.statusCode);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('Response data: $data'); //response data
        if (data.isNotEmpty) {
          setState(() {
            _userDetails = data[0]; //get the first item in the list
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No user details found';
          });
        }
      } else {
        // Handle error
        print('Failed to load user details: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load user details';
        });
      }
    } catch (error) {
      //error handlind
      print('Error fetching user details: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching user details';
      });
    }
  }

  Future<void> fetchRecipes() async {
    final url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getUserRecipes', 'userId': _userId});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);

        for (var recipe in fetchedRecipes) {
          final String recipeId = recipe['recipeid'];
          await fetchRecipeDetails(recipeId);
        }
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }
  }

  Future<void> fetchRecipeDetails(String recipeId) async {
    final url = 'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedRecipe = jsonDecode(response.body);

        setState(() {
          recipes.add(fetchedRecipe);
        });
      } else {
        print('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipe details: $error');
    }
  }

  String getSpiceLevelText(String spiceLevel) {
    switch (spiceLevel) {
      case '1':
        return 'None';
      case '2':
        return 'Mild';
      case '3':
        return 'Medium';
      case '4':
        return 'Hot';
      case '5':
        return 'Extra Hot';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20493C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.white)))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildHeader(context),
                                const SizedBox(height: 20),
                                buildProfileInfo(),
                                const SizedBox(height: 20),
                                buildPreferences(),
                                const SizedBox(height: 20),
                                buildMyRecipes(),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildHeader(context),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildProfileInfo(),
                                    const SizedBox(width: 32),
                                    Expanded(child: buildPreferences()),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                buildMyRecipes(),
                              ],
                            );
                          }
                        },
                      ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileEditScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildProfileInfo() {
    final String username =
        _userDetails?['username']?.toString() ?? 'Jane Doe'; //default values
    final String email = 'jane.doe@gmail.com'; //default
    final String profilePhoto =
        _userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: profilePhoto.startsWith('http') //profile photo
              ? Image.network(
                  profilePhoto,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  profilePhoto,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: 16),
        Text(
          username,

          ///username
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          email, //user email
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            // Handle sign out
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildPreferences() {
    final String spiceLevel =
        _userDetails?['spicelevel']?.toString() ?? 'Mild'; //default
    final String preferredCuisine =
        _userDetails?['cuisine']?.toString() ?? 'Mexican'; //default
    final List<String> dietaryConstraints = List<String>.from(
        _userDetails?['dietaryConstraints']?.map((dc) => dc.toString()) ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spice Level
        Text(
          'Spice Level',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            Chip(
              label: Text(getSpiceLevelText(spiceLevel)), //spice level
              backgroundColor: Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Preferred Cuisine
        Text(
          'Preferred Cuisine',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            Chip(
              label: Text(preferredCuisine), //preferred cuisine
              backgroundColor: Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Dietary Constraints
        Text(
          'Dietary Constraints',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: dietaryConstraints
              .map(
                (constraint) => Chip(
                  label: Text(constraint), //list of constraints
                  backgroundColor: Colors.grey[700],
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget buildMyRecipes() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'My Recipes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double itemWidth = width / 5-16;
          double itemHeight = itemWidth * 1.2;
          double aspectRatio = itemWidth / itemHeight;

          double crossAxisSpacing = 8.0;
          double mainAxisSpacing = 8.0;

          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              List<String> keywords =
                  (recipes[index]['keywords'] as String?)?.split(', ') ?? [];
              List<String> steps = [];
              if (recipes[index]['steps'] != null) {
                steps = (recipes[index]['steps'] as String).split(',');
              }

              return RecipeCard(
                name: recipes[index]['name'] ?? '',
                description: recipes[index]['description'] ?? '',
                imagePath: recipes[index]['photo'] ?? 'assets/pfp.jpg',
                prepTime: recipes[index]['preptime'] ?? 0,
                cookTime: recipes[index]['cooktime'] ?? 0,
                cuisine: recipes[index]['cuisine'] ?? '',
                spiceLevel: recipes[index]['spicelevel'] ?? 0,
                course: recipes[index]['course'] ?? '',
                servings: recipes[index]['servings'] ?? 0,
                keyWords: keywords,
                steps: steps,
                appliances: List<String>.from(recipes[index]['appliances']),
                ingredients: List<Map<String, dynamic>>.from(recipes[index]['ingredients']),
              );
            },
          );
        },
      ),
    ],
  );
}


  // Widget recipeCard(String imagePath) {
  //   return Container(
  //     width: 200,
  //     margin: const EdgeInsets.only(right: 16),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       image: DecorationImage(
  //         image: AssetImage(imagePath),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }
}
