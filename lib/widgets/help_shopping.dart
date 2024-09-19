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

    final clickColor = theme.brightness == Brightness.light
        ? Color(0xFFEDEDED)
        : Color(0xFF283330);

    final fontColor = getFontColor(context);

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Color.fromARGB(121, 0, 0, 0), // Semi-transparent background
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: clickColor,
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
                        Image.asset(theme.brightness == Brightness.light ? 'assets/light_helper_chef.png' : 'assets/helper_chef.png', height: 80),
                        SizedBox(height: 10),
                        Text(
                          'How may I help you?',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: fontColor),
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
                          _buildSectionTitle('Contact Us', fontColor),
                          _buildParagraph(
                              'If you encounter any issues or have any queries that could not be answered through the FAQs, feel free to reach out to us. We are here to help!',
                              fontColor),
                          _buildLink(
                              'tecktonic.capstone@gmail.com',
                              'mailto:tecktonic.capstone@gmail.com?subject=Help Request&body=I need help with...',
                              fontColor),
                          SizedBox(height: 20),
                          _buildSectionTitle('How it works', fontColor),
                          _buildInstructionalContent(fontColor),
                          SizedBox(height: 20),
                          _buildSectionTitle(
                              'Frequently Asked Questions', fontColor),
                          _buildFAQs(fontColor),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      key: ValueKey('close_help_menu'),
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

  Widget _buildSectionTitle(String title, Color fontColor) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: fontColor),
    );
  }

  Widget _buildParagraph(String text, Color fontColor) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, color: fontColor),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildLink(String text, String url, Color fontColor) {
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

  Widget _buildInstructionalContent(Color fontColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSectionTitle('Navigating the Shopping List Page', fontColor),
        _buildParagraph(
            'The shopping list is where you can easily add or remove necessary ingredients for our delicious recipes. Here’s how you can navigate and use it effectively:',
            fontColor),
        _buildStep(
            '1',
            'Tap the "+" button at the bottom of the screen.',
            fontColor),
        _buildStep(
            '2',
            'Enter the ingredient name in the "Item Name" field.',
            fontColor),
        _buildStep(
            '3',
            'Enter the quantity in the "Quantity" field.',
            fontColor),
        _buildStep(
            '4',
            'Tap "Add" to add the ingredient to the shopping list.',
            fontColor),
        _buildStep(
            '5',
            'To edit the quantity, locate the ingredient you wish to edit and tap the pencil icon next to it to edit it.',
            fontColor),
        _buildStep(
            '6',
            'To delete an ingredient from your shopping list, locate the ingredient you wish to remove and tap the trash can icon next to it to delete it.',
            fontColor),
      ],
    );
  }

  Widget _buildSubSectionTitle(String title, Color fontColor) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: fontColor),
      ),
    );
  }

  Widget _buildStep(
      String stepNumber, String stepDescription, Color fontColor) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber. ',
            style: TextStyle(fontSize: 16, color: fontColor),
          ),
          Expanded(
            child: Text(
              stepDescription,
              style: TextStyle(fontSize: 16, color: fontColor),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQs(Color fontColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQ(
            'Q: How can I edit my dietary preferences?',
            'A: Go to the "Profile" section and update your dietary preferences. This will help us suggest recipes that match your dietary needs.',
            fontColor),
        _buildFAQ(
            'Q: How do I navigate to the Home page?',
            'A: Tap on the "Home" section in the navbar to return to the Home page at any time.',
            fontColor),
        _buildFAQ(
            'Q: How do I add a new recipe?',
            'A: Navigate to the "Add Recipe" section by tapping on the "Add Recipe" tab and fill in the required details to share your recipe with the community.',
            fontColor),
        _buildFAQ(
            'Q: How can I manage my shopping list?',
            'A: Go to the "Inventory" section to access the "Shopping List" to view and manage your shopping items.',
            fontColor),
        _buildFAQ(
            'Q: How do I keep track of items in my pantry?',
            'A: Go to the "Inventory" section to access the "Pantry" where you can add, edit, and remove items.',
            fontColor),
        _buildFAQ(
            'Q: Where can I manage my kitchen appliances?',
            'A: Go to the "Inventory" section to access the "Appliances" tab to view and manage your kitchen appliances.',
            fontColor),
        _buildFAQ(
            'Q: Where can I search for specific recipes?',
            'A: Go to the "Search Recipes" section to be able to search for recipes by name, ingredients and filter according to your preferences.',
            fontColor),
        _buildFAQ(
            'Q: How do I view my saved recipes?',
            'A: Navigate to the "Saved Recipes" section by tapping on the "Saved Recipes" tab to see all your saved recipes.',
            fontColor),
        _buildFAQ(
            'Q: How can I update my profile information?',
            'A: Go to the "Profile" section by tapping on the "Profile" tab to update your profile information.',
            fontColor),
      ],
    );
  }

  Widget _buildFAQ(String question, String answer, Color fontColor) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: fontColor),
          ),
          SizedBox(height: 5),
          Text(
            answer,
            style: TextStyle(fontSize: 16, color: fontColor),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
