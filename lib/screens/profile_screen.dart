import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile.jpeg'), // Your profile image asset
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'John Doe',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            SizedBox(height: 32),
            ListTile(
              leading: Icon(Icons.email, color: Colors.white),
              title: Text('john.doe@example.com', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.white),
              title: Text('+1 234 567 890', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.white),
              title: Text('123 Main St, Anytown, USA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
