import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      body: Stack(
        children: [
          //Background image
          Positioned.fill(
            child: Image.asset(
              isMobile
                  ? (isLightTheme ? 'MobileLightMode.png' : 'MobileDarkMode.png')
                  : (isLightTheme ? 'assets/Lightmode.png' : 'Darkermode.png'),
              fit: BoxFit.cover,
            ),
          ),
          //Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  isLightTheme ? 'assets/logo_1.png' : 'assets/logo_2.png',
                  height: 100,
                ),
                SizedBox(height: 32), //spacing between logo and buttons
                //Login button
                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    key: ValueKey('loginButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC945F), //Button color
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                //Line with "or" text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 1,
                      color: isLightTheme
                          ? const Color.fromARGB(255, 94, 94, 94)
                          : Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: isLightTheme
                              ? const Color.fromARGB(255, 94, 94, 94)
                              : Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 1,
                      color: isLightTheme
                          ? const Color.fromARGB(255, 94, 94, 94)
                          : Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 16), //Spacing between line and button
                //Sign up button
                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    key: ValueKey('signupButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, //Button color
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1A2D27),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
