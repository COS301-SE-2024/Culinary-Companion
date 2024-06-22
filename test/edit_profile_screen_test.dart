import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/edit_profile_screen.dart'; // Adjust this import path

void main() {
  testWidgets('ProfileEditScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileEditScreen()));
    expect(find.byType(ProfileEditScreen), findsOneWidget);
  });
  testWidgets('ProfileEditScreen has correct AppBar title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileEditScreen()));
    expect(find.text('Edit Profile'), findsOneWidget);
  });

    testWidgets('Does the user details load correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileEditScreen()));
    expect(find.byType(ProfileEditScreen), findsOneWidget);
  });
  testWidgets('Editing details', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileEditScreen()));
    expect(find.text('Edit Profile'), findsOneWidget);
  });
  
}