import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen_test.mocks.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/edit_profile_screen.dart';
import 'package:lottie/lottie.dart';
@GenerateMocks([http.Client, SharedPreferences])
void main() {
  late MockClient mockClient;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockClient = MockClient();
    mockSharedPreferences = MockSharedPreferences();
  });

  testWidgets('ProfileScreen displays loading indicator initially', (WidgetTester tester) async {
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