import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Getting the screen size
    // final size = MediaQuery.of(context).size;
    // final buttonWidth = size.width * 0.2;
    // final logoHeight = size.height * 0.2;
    // final textSize = size.width * 0.08;

    return Scaffold(
      body: Stack(
        children: [
          //Background image
          Positioned.fill(
            child: Image.asset(
              'assets/Darkmode.png',
              fit: BoxFit.cover,
            ),
          ),
          //Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 100,
                ),
                SizedBox(height: 32),//spacing between logo and buttons
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
                      color: Colors.white,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 1,
                      color: Colors.white,
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
