import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpMenu extends StatelessWidget {
  final VoidCallback onClose;

  HelpMenu({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Color.fromARGB(121, 0, 0, 0), // Semi-transparent background
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFF20493C), // Dark green background color
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset('helper_chef.png', height: 80),
                        SizedBox(height: 10),
                        Text(
                          'How may I help you?',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Us',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Contact us by clicking on the link below if you encounter any issues or have any queries that could not be answered through the FAQs.',
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',
                                path: 'tecktonic.capstone@gmail.com',
                                query:
                                    'subject=Help Request&body=I need help with...',
                              );
                              if (await canLaunch(emailUri.toString())) {
                                await launch(emailUri.toString());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not launch email app'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'tecktonic.capstone@gmail.com',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'How it works',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '1. Updating my preferences',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '1.1. This is the Profile page.\n'
                            '1.2. Here you can view all your information and preferences.\n'
                            '1.3. At the bottom of the screen, you can see the recipes you created.\n'
                            '1.4. Click on the gear button on the Profile Page to navigate to the Edit Profile page.\n'
                            '1.5. In the Edit Profile Page, you will find fields to update your preferred cuisine, spice level, and dietary constraints.\n',
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Frequently Asked Questions',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How can I edit my dietary preferences?\nA: Go to the "Profile" section and update your dietary preferences.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How do I navigate to the Home page?\nA: Tap on the "Home" tab in the navbar to return to the Home page.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How do I add a new recipe?\nA: Navigate to the "Add Recipe" section by tapping on the "Add Recipe" tab and fill in the required details.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How can I manage my shopping list?\nA: Go to the "Shopping List" section by tapping on the "Shopping List" tab to view and manage your shopping items.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How do I keep track of items in my pantry?\nA: Use the "Pantry" tab to access the "Pantry List" where you can add, edit, and remove items.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: Where can I manage my kitchen appliances?\nA: Tap on the "Appliances" tab to view and manage your kitchen appliances.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How do I view my saved recipes?\nA: Navigate to the "Saved Recipes" section by tapping on the "Saved Recipes" tab to see all your saved recipes.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Q: How can I update my profile information?\nA: Go to the "Profile" section by tapping on the "Profile" tab to update your profile information.',
                          ),
                          SizedBox(height: 8),

                          // Add more FAQ entries as needed
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                        onPressed: onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDC945F),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text('Close',
                            style: TextStyle(color: Colors.white))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}