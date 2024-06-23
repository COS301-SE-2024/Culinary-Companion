import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:lottie/lottie.dart';
@GenerateMocks([http.Client, SharedPreferences])
void main() {
  testWidgets('ProfileScreen displays loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
    expect(find.byType(Lottie), findsOneWidget);
  });

  testWidgets('Profile screen loads user data', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
    expect(find.byType(Lottie), findsOneWidget);
  });

  testWidgets('ProfileScreen displays error message when userId is null', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(MaterialApp(home: ProfileScreen()));
    await tester.pump();
    await tester.pump(Duration(seconds: 5));

    expect(find.text('User ID not found'), findsOneWidget);
  });
}
