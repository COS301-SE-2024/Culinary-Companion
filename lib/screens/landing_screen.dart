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
                  ? (isLightTheme ? 'assets/MobileLightMode.png' : 'assets/MobileDarkMode.png')
                  : (isLightTheme ? 'assets/Lightmode.png' : 'assets/Darkermode.png'),
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
                SizedBox(height: 16),
                //Guest button
                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    key: ValueKey('guestButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, //Button color
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/guest_home');
                    },
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
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
