import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/recipe_card.dart';
import 'package:lottie/lottie.dart';
import '../widgets/help_profile.dart';
import 'landing_screen.dart';

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
  OverlayEntry? _helpMenuOverlay;

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
      //print('Login successful: $_userId');
    });
    if (_userId != null) {
      await _fetchUserDetails();
      await fetchRecipes(); //Fetch user recipes after fetching user details
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

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final String url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/userEndpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'getUserDetails', 'userId': _userId}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _userDetails = data[0]; // Get the first item in the list
          });
        } else {
          setState(() {
            _errorMessage = 'No user details found';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load user details';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching user details';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  Future<void> fetchRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getUserRecipes', 'userId': _userId});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

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
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getRecipe', 'recipeid': recipeId});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> fetchedRecipe = jsonDecode(response.body);

        setState(() {
          recipes.add(fetchedRecipe);
        });
      } else {
        print('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (error) {
      //print('Error fetching recipe details: $error');
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

  void _showHelpMenu() {
    _helpMenuOverlay = OverlayEntry(
      builder: (context) => HelpMenu(
        onClose: () {
          _helpMenuOverlay?.remove();
          _helpMenuOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_helpMenuOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textColor = theme.brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(top: 30, left: 38.0),
          child: Text(
            'Account',
            style: TextStyle(
              fontSize: 24.0, // Set the font size for h2 equivalent
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: Icon(Icons.help),
              onPressed: _showHelpMenu,
              iconSize: 35,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 20.0),
            child: _isLoading
                ? Center(
                    child: Lottie.asset('assets/loading.json'),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: theme.brightness == Brightness.light
                                  ? Color(0xFF1E1E1E)
                                  : Color(0xFFD9D9D9)),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildHeader(context),
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
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.light
        ? Color(0xFF1E1E1E)
        : Color(0xFFD9D9D9);

    final String username =
        _userDetails?['username']?.toString() ?? 'Jane Doe'; //default values
    final String profilePhoto =
        _userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';
    //final String email = 'jane.doe@gmail.com'; //default

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(180),
                  child: profilePhoto.startsWith('http')
                      ? Image.network(
                          profilePhoto,
                          width: 240,
                          height: 240,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          profilePhoto,
                          width: 240,
                          height: 240,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: 5),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileEditScreen(),
                          ),
                        );

                        if (result == true) {
                          // Reload user details if the profile was updated
                          await _fetchUserDetails();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: textColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: const Color(0xFFDC945F),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 25),
                    OutlinedButton(
                      onPressed: () async {
                        // Clear shared preferences
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();

                        // Navigate to LandingScreen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LandingScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: textColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        foregroundColor: const Color(0xFFDC945F),
                      ),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 20),
            Column(
              children: [
                const SizedBox(height: 25, width: 50),
                buildPreferences(),
              ],
            )
          ],
        ));
  }

  Widget buildPreferences() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.light
        ? Color(0xFF1E1E1E)
        : Color(0xFFD9D9D9);

    final String spiceLevel =
        _userDetails?['spicelevel']?.toString() ?? 'Mild'; //default
    final String preferredCuisine =
        _userDetails?['cuisine']?.toString() ?? 'Mexican'; //default
    final List<String> dietaryConstraints = List<String>.from(
        _userDetails?['dietaryConstraints']?.map((dc) => dc.toString()) ?? []);

    return Container(
        height: screenHeight * 0.3,
        width: screenWidth * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Color(0xFFF1F1F1)
              : Color(0xFF2E2E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.light
                ? Color(0xFFD1D1D1)
                : Color(0xFF4E4E4E),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spice Level
            Text(
              'Spice Level',
              style: TextStyle(
                color: textColor,
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
                color: textColor,
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
                color: textColor,
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
        ));
  }

  Widget buildMyRecipes() {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.light
        ? Color(0xFF1E1E1E)
        : Color(0xFFD9D9D9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Recipes',
          style: TextStyle(
            color: textColor,
            fontSize: 24, //18
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double itemWidth = width / 5 - 16;
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
                // List<String> keywords =
                //     (recipes[index]['keywords'] as String?)?.split(', ') ?? [];
                List<String> steps = [];
                if (recipes[index]['steps'] != null) {
                  steps = (recipes[index]['steps'] as String).split(',');
                }

                return RecipeCard(
                  recipeID: recipes[index]['recipeId'] ?? '',
                  name: recipes[index]['name'] ?? '',
                  description: recipes[index]['description'] ?? '',
                  imagePath: recipes[index]['photo'] ?? 'assets/emptyPlate.jpg',
                  prepTime: recipes[index]['preptime'] ?? 0,
                  cookTime: recipes[index]['cooktime'] ?? 0,
                  cuisine: recipes[index]['cuisine'] ?? '',
                  spiceLevel: recipes[index]['spicelevel'] ?? 0,
                  course: recipes[index]['course'] ?? '',
                  servings: recipes[index]['servings'] ?? 0,
                  steps: steps,
                  appliances: List<String>.from(recipes[index]['appliances']),
                  ingredients: List<Map<String, dynamic>>.from(
                      recipes[index]['ingredients']),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
