import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'widgets/theme_notifier.dart'; // Import your ThemeNotifier
import 'screens/landing_screen.dart'; // Import the new landing screen
import 'screens/login_screen.dart'; // Import the new login screen
import 'screens/signup_screen.dart';
import 'screens/tutorial_pages.dart';
import 'screens/confirm_details.dart'; //Import the confirm details, a.k.a Signup 2 page
import 'screens/main.dart'; // Import the main screen
import 'guest/guest_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; //LLM

void main() async {
  await dotenv.load(); //LLM
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gsnhwvqprmdticzglwdf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdzbmh3dnFwcm1kdGljemdsd2RmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTY2MzAwNzgsImV4cCI6MjAzMjIwNjA3OH0.1VIuJzuMHBLFC6EduaGCOk0IPoIBdkOJsF2FwrqcP7Y',
  );

  // Initialize the shared preferences and http client
  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();

  runApp(CulinaryCompanionApp(
    sharedPreferences: sharedPreferences,
    httpClient: httpClient,
  ));
}

class CulinaryCompanionApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final http.Client httpClient;

  CulinaryCompanionApp({
    required this.sharedPreferences,
    required this.httpClient,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(prefs: sharedPreferences),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Culinary Companion',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor:
                    Color(0xFFDC945F), // Replace this with your seed color
                brightness:
                    Brightness.light, // or Brightness.dark for dark theme
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(),
              primarySwatch: Colors.green,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Color(0xFFEDEDED),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black12,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor:
                    Color(0xFFEDEDED), // Replace this with your seed color
                brightness:
                    Brightness.dark, // or Brightness.dark for dark theme
              ),
              textTheme: GoogleFonts.interTextTheme().apply(
                bodyColor: Color(0xFFD9D9D9),
                displayColor: Color(0xFFD9D9D9),
              ),
              primarySwatch: Colors.green,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF283330),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white12,
              ),
            ),
            themeMode: themeNotifier.currentTheme,
            // themeMode: ThemeMode.system, // Use system theme setting
            //themeMode: ThemeMode.light,
            //themeMode: ThemeMode.dark,
            initialRoute:
                '/landing', // Set the initial route to the landing screen
            routes: {
              '/landing': (context) =>
                  LandingScreen(), // Add the landing screen route
              '/login': (context) =>
                  LoginScreen(), // Add the login screen route
              '/signup': (context) => SignupScreen(
                    httpClient: httpClient,
                    sharedPreferences: sharedPreferences,
                  ), // Add the signup screen route
              '/home': (context) => MainScreen(), // Rename the home route
              '/confirm': (context) => ConfirmDetailsScreen(),
              '/tutorial': (context) => TutorialPages(),
              '/guest_home': (context) => MainScreen2(),
            },
          );
        },
      ),
    );
  }
}
