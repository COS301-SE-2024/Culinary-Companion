import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Color getFontColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.light
      ? const Color.fromARGB(255, 49, 49, 49)
      : const Color.fromARGB(255, 255, 255, 255);
}

class HelpMenu extends StatelessWidget {
  final VoidCallback onClose;

  HelpMenu({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ClickColor = theme.brightness == Brightness.light
        ? Colors.white
        : Color.fromARGB(255, 25, 58, 48);

    final FontColor = getFontColor(context);

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Color.fromARGB(121, 0, 0, 0), // Semi-transparent background
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: ClickColor,
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: FontColor),
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
                          _buildSectionTitle('Contact Us', FontColor),
                          _buildParagraph(
                              'If you encounter any issues or have any queries that could not be answered through the FAQs, feel free to reach out to us. We are here to help!',
                              FontColor),
                          _buildLink(
                              'tecktonic.capstone@gmail.com',
                              'mailto:tecktonic.capstone@gmail.com?subject=Help Request&body=I need help with...',
                              FontColor),
                          SizedBox(height: 20),
                          _buildSectionTitle('How it works', FontColor),
                          _buildInstructionalContent(FontColor),
                          SizedBox(height: 20),
                          _buildSectionTitle(
                              'Frequently Asked Questions', FontColor),
                          _buildFAQs(FontColor),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child:
                          Text('Close', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color FontColor) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: FontColor),
    );
  }

  Widget _buildParagraph(String text, Color FontColor) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, color: FontColor),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildLink(String text, String url, Color FontColor) {
    return InkWell(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {}
      },
      child: Text(
        text,
        style:
            TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _buildInstructionalContent(Color FontColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('1. Navigating the Home Page', FontColor),
        _buildParagraph(
            'The home page is your gateway to all the delicious recipes. Here’s how you can navigate and use it effectively:',
            FontColor),
        _buildStep(
            '1.1',
            'Scroll up and down to view all available recipes. Each recipe card provides a brief overview, including the recipe name and an enticing image.',
            FontColor),
        _buildStep(
            '1.2',
            'Hover over any of the recipes to see additional details such as the recipe name, description, prep time, cook time, cuisine, spice level, course, servings, steps, appliances, and ingredients.',
            FontColor),
        _buildStep(
            '1.3',
            'Tap on any recipe card to view detailed information about the recipe, including step-by-step instructions and a complete list of ingredients.',
            FontColor),
        _buildStep(
            '1.4',
            'Use the search bar at the top of the screen to quickly find recipes by name, ingredients, or cuisine type.',
            FontColor),
        _buildStep(
            '1.5',
            'Filter recipes based on dietary preferences, cook time, and difficulty level using the filter options available on the home page.',
            FontColor),
      ],
    );
  }

  Widget _buildSubSectionTitle(String title, Color FontColor) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: FontColor),
      ),
    );
  }

  Widget _buildStep(
      String stepNumber, String stepDescription, Color FontColor) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber. ',
            style: TextStyle(fontSize: 16, color: FontColor),
          ),
          Expanded(
            child: Text(
              stepDescription,
              style: TextStyle(fontSize: 16, color: FontColor),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQs(Color FontColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQ(
            'Q: How can I edit my dietary preferences?',
            'A: Go to the "Profile" section and update your dietary preferences. This will help us suggest recipes that match your dietary needs.',
            FontColor),
        _buildFAQ(
            'Q: How do I navigate to the Home page?',
            'A: Tap on the "Home" tab in the navbar to return to the Home page at any time.',
            FontColor),
        _buildFAQ(
            'Q: How do I add a new recipe?',
            'A: Navigate to the "Add Recipe" section by tapping on the "Add Recipe" tab and fill in the required details to share your recipe with the community.',
            FontColor),
        _buildFAQ(
            'Q: How can I manage my shopping list?',
            'A: Go to the "Shopping List" section by tapping on the "Shopping List" tab to view and manage your shopping items.',
            FontColor),
        _buildFAQ(
            'Q: How do I keep track of items in my pantry?',
            'A: Use the "Pantry" tab to access the "Pantry List" where you can add, edit, and remove items.',
            FontColor),
        _buildFAQ(
            'Q: Where can I manage my kitchen appliances?',
            'A: Tap on the "Appliances" tab to view and manage your kitchen appliances.',
            FontColor),
        _buildFAQ(
            'Q: How do I view my saved recipes?',
            'A: Navigate to the "Saved Recipes" section by tapping on the "Saved Recipes" tab to see all your saved recipes.',
            FontColor),
        _buildFAQ(
            'Q: How can I update my profile information?',
            'A: Go to the "Profile" section by tapping on the "Profile" tab to update your profile information.',
            FontColor),
      ],
    );
  }

  Widget _buildFAQ(String question, String answer, Color FontColor) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: FontColor),
          ),
          SizedBox(height: 5),
          Text(
            answer,
            style: TextStyle(fontSize: 16, color: FontColor),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
