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
            color: Color(0xFF20493C),
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
                            'Contact us by clicking on the link below if you encounter any issues or have any queries that could not be answered through the FAQs.', //will have link to something?
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
                              // ignore: deprecated_member_use
                              if (await canLaunch(emailUri.toString())) {
                                // ignore: deprecated_member_use
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
                            '1. Navigating the Home Page', //will have link to something?
                          ),
                          SizedBox(height: 8),
                          Text(
                            '1.1. Scroll up and down to view all recipes.\n'
                            '1.2. Hover over any of the recipes to see details such as the recipe name, description, prep time, cook time, cuisine, spice level, course, servings, steps, appliances, and ingredients.\n'
                            '1.3. Tap on any recipe card to view detailed information about the recipe.\n'
                          ),
                          SizedBox(height: 8),
                          Text(
                            '2. Recipe Scanning and Formatting', //will have link to something?
                          ),
                          SizedBox(height: 8),
                          Text(
                            '2.1. Navigate to the Add Recipe page: ',
                          ),
                          Text(
                            '2.2. Open the "Add My Own Recipe" tab.',
                          ),
                          Text(
                            '2.3. Fill in the relevant fields for adding a recipe.',
                          ),
                          Text(
                            '2.4. Adjust the spice level of the recipe by moving the slider to the preferred spice level.',
                          ),
                          Text(
                            '2.5. Adjust serving amount by using the less (-) and more (+) button.',
                          ),
                          Text(
                            '2.6. Add ingredients by clicking on the "+" button.',
                          ),
                          Text(
                            '2.7. Add methods by clicking on the "+" button.',
                          ),
                          Text(
                            '2.8. Add appliances by clicking on the "+" button.',
                          ),
                          Text(
                            '2.9. Click on the "Add recipe" button to add the recipe.\n',
                          ),
                          SizedBox(height: 8),
                          Text(
                            '3. Adding and removing ingredients in my shopping list', //will have link to something?
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Adding ingredients to the shopping list: ',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '3.1. Tap the "+" button at the bottom of the screen.\n'
                            '3.2. Select a category from the "Select Food Type" dropdown.\n'
                            '3.3. Enter the ingredient name in the "Enter item name" field.\n'
                            '3.4. Tap "Add" to add the ingredient to the shopping list.',
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Removing ingredients from the shopping list: ',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '3.1. Locate the ingredient in the shopping list.\n'
                            '3.2. Tap the trash can icon next to the ingredient.\n'
                            '3.3. Confirm the removal in the dialog that appears by tapping "Remove".\n',
                          ),
                          SizedBox(height: 8),
                          Text(
                            '4. Adding and removing ingredients in my pantry', //will have link to something?
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Adding ingredients to the pantry: ',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '4.1. Tap the "+" button at the bottom of the screen.\n'
                            '4.2. Select a category from the "Select Food Type" dropdown.\n'
                            '4.3. Enter the ingredient name in the "Enter item name" field.\n'
                            '4.4. Tap "Add" to add the ingredient to the pantry.',
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Removing ingredients from the pantry: ',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '4.1. Locate the ingredient in the pantry.\n'
                            '4.2. Tap the trash can icon next to the ingredient.\n'
                            '4.3. Confirm the removal in the dialog that appears by tapping "Remove".\n',
                          ),
                          SizedBox(height: 8),
                          Text(
                            '5. Adding and removing appliances', //will have link to something?
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Adding appliances: ',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '5.1. Tap the "+" button at the bottom of the screen.\n'
                            '5.2. Enter the appliance name in appliance field.\n'
                            '5.4. Tap "Add" to add the appliance.',
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            'Removing appliances: ',
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '5.1. Locate the appliance you wish to remove.\n'
                            '5.2. Tap the trash can icon next to the appliance.\n',
                          ),
                          // SizedBox(height: 8),
                          // Text(
                          //   '6. Saving recipes', //will have link to something?
                          // ),
                          SizedBox(height: 8),
                          Text(
                            '6. Updating my preferences', //will have link to something?
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '6.1. Navigate to the Profile Page./n'
                            '6.2. Click on the gear button on the Profile Page to navigate to the Edit Profile page.\n'
                            '6.3. In the Edit Profile Page, you will find fields to update your preferred cuisine, spice level and dietary constraints.\n',
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
