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
    if (mounted) {
      setState(() {
        _userId = prefs.getString('userId');
        //print('Login successful: $_userId');
      });
    }
    if (_userId != null) {
      await _fetchUserDetails();
      await fetchRecipes(); //Fetch user recipes after fetching user details
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found';
        });
      }
    }
  }

///////////fetch the users profile details/////////
  Future<void> _fetchUserDetails() async {
    if (_userId == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedUserDetails = prefs.getString('cached_user_details');

    if (cachedUserDetails != null && _userDetails == null) {
      setState(() {
        _userDetails = jsonDecode(cachedUserDetails);
      });
    }

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

          // Cache user details for future use
          await prefs.setString(
              'cached_user_details', jsonEncode(_userDetails));
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
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading indicator
        });
      }
    }
  }

  Future<void> fetchRecipes() async {
    final url =
        'https://gsnhwvqprmdticzglwdf.supabase.co/functions/v1/ingredientsEndpoint';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = jsonEncode({'action': 'getUserRecipes', 'userId': _userId});

    try {
      // Load cached recipes first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedRecipes = prefs.getString('cached_user_recipes');

      if (cachedRecipes != null) {
        if (recipes.isEmpty) {
          setState(() {
            recipes =
                List<Map<String, dynamic>>.from(jsonDecode(cachedRecipes));
          });
        }
      }

      // Fetch fresh recipes from Supabase
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> fetchedRecipes = jsonDecode(response.body);

        // Clear the recipes list to avoid duplication
        recipes.clear();

        // Fetch recipe details in parallel
        List<Future<void>> recipeFutures = [];
        for (var recipe in fetchedRecipes) {
          final String recipeId = recipe['recipeid'];
          recipeFutures.add(fetchRecipeDetails(recipeId));
        }

        await Future.wait(recipeFutures);

        // Cache the fetched recipes
        await prefs.setString('cached_user_recipes', jsonEncode(recipes));
      } else {
        print('Failed to load recipes: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }

    // Ensure loading spinner is hidden once data is fetched
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
        if (mounted) {
          setState(() {
            recipes.add(fetchedRecipe);
          });
        }
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
    final screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);
    //final textColor = theme.brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(top: 100, left: 30.0, bottom: 70),
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
            padding: const EdgeInsets.only(top: 10, right: 20.0),
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
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
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
                                SizedBox(height: screenHeight * 20 / 730),
                                //buildPreferences(),
                                // SizedBox(height: screenHeight * 20 / 730),
                                buildMyRecipes(),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildHeader(context),
                                SizedBox(height: screenHeight * 20 / 730),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.light
        ? Color(0xFF1E1E1E)
        : Color(0xFFD9D9D9);

    final String username =
        _userDetails?['username']?.toString() ?? 'Jane Doe'; // default values
    final String profilePhoto =
        _userDetails?['profilephoto']?.toString() ?? 'assets/pfp.jpg';

    Widget preferencesWidget = buildPreferences();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 738;

          return isSmallScreen
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(360),
                      child: profilePhoto.startsWith('http')
                          ? Image.network(
                              profilePhoto,
                              width: screenWidth * 0.3,
                              height: screenWidth * 0.3,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              profilePhoto,
                              width: screenWidth * 0.3,
                              height: screenWidth * 0.3,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(height: screenHeight * 5 / 730),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 10 / 730),
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          SizedBox(width: screenWidth * 10 / 1519),
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
                    ),
                    SizedBox(height: screenHeight * 20 / 730),
                    preferencesWidget,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(360),
                          child: profilePhoto.startsWith('http')
                              ? Image.network(
                                  profilePhoto,
                                  width: screenWidth * 240 / 1519,
                                  height: screenWidth * 240 / 1519,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  profilePhoto,
                                  width: screenWidth * 240 / 1519,
                                  height: screenWidth * 240 / 1519,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(height: screenHeight * 5 / 730),
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 20 / 730),
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
                                style:
                                    TextStyle(color: textColor, fontSize: 16),
                              ),
                            ),
                            SizedBox(width: screenWidth * 10 / 1519),
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
                                style:
                                    TextStyle(color: textColor, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: screenWidth * 20 / 1519),
                    Expanded(child: preferencesWidget),
                  ],
                );
        },
      ),
    );
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

    final double containerWidth = screenWidth > 937
        ? screenWidth * 0.6
        : screenWidth < 738
            ? screenWidth * 0.87
            : screenWidth * 0.87;

    return Container(
      //height: screenHeight * 300 / 730,
      width: containerWidth,

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
      child: SingleChildScrollView(
        // Added to make the content scrollable
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
            SizedBox(height: screenHeight * 8 / 730),
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
            SizedBox(height: screenHeight * 24 / 730),
            // Preferred Cuisine
            Text(
              'Preferred Cuisine',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 8 / 730),
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
            SizedBox(height: screenHeight * 24 / 730),
            // Dietary Constraints
            Text(
              'Dietary Constraints',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 8 / 730),
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
        ),
      ),
    );
  }

  Widget buildMyRecipes() {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double itemWidth;
            double itemHeight;
            double aspectRatio;
            int crossAxisCount =
                4; // Default number of columns for large screens

            // Adjust values for screens smaller than 650px
            if (width < 650) {
              crossAxisCount = 3; // Mobile view
              itemWidth = width / 3 - 16; // Adjust width for mobile
              itemHeight = itemWidth * 1.5; // Increase height for mobile
              aspectRatio = itemWidth / itemHeight; // Adjust aspect ratio
            } else {
              itemWidth = width / 5 - 16; // Default width for larger screens
              itemHeight = itemWidth * 1.2; // Default height for larger screens
              aspectRatio = itemWidth / itemHeight; // Default aspect ratio
            }

            double crossAxisSpacing = 8.0;
            double mainAxisSpacing = 8.0;

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recipes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                List<String> steps = [];
                if (recipes[index]['steps'] != null) {
                  steps = (recipes[index]['steps'] as String).split('<');
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
                  customBoxWidth:
                      width < 760 ? screenWidth / 5 : screenWidth / 7,
                  // Custom properties for different screen sizes
                  customFontSizeTitle: width < 450
                      ? 12 // Smaller font size for screens less than 450px
                      : (width < 550
                          ? 14 // Smaller font size for screens less than 550px
                          : (width < 650
                              ? 16
                              : 18)), // Different font sizes for larger screens
                  customIconSize: width < 450
                      ? 18 // Smaller icon size for screens less than 450px
                      : (width < 550
                          ? 20 // Smaller icon size for screens less than 550px
                          : (width < 650
                              ? 24
                              : 28)), // Different icon sizes for larger screens
                  // Different icon sizes for mobile and tablet
                );
              },
            );
          },
        ),
      ],
    );
  }
}
