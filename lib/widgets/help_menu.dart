import 'package:flutter/material.dart';

class HelpMenu extends StatelessWidget {
  final VoidCallback onClose;

  HelpMenu({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54, // Semi-transparent background
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help Menu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '1. How to use the app',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To use the app, you can browse recipes, view details, and add new recipes.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    '2. Frequently Asked Questions',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Here you can find answers to the most common questions.',
                  ),
                  // Add more help content as needed
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: onClose,
                      child: Text('Close'),
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
}
