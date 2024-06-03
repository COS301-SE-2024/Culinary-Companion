import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../lib/screens/signup_screen.dart';

@GenerateMocks([], customMocks: [
  MockSpec<http.Client>(as: #MockHttpClient),
  MockSpec<SharedPreferences>(as: #MockSharedPreferences),
])
import 'signup_screen_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SignupScreen Tests', () {
    late MockHttpClient mockHttpClient;
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockSharedPreferences = MockSharedPreferences();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: SignupScreen(
          httpClient: mockHttpClient,
          sharedPreferences: mockSharedPreferences,
        ),
        routes: {
          '/home': (context) => Scaffold(body: Text('Home Screen')),
        },
      );
    }

    testWidgets('should display all input fields and buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('should show error if email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error if passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password456');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should call sign up API and save user ID on success', (WidgetTester tester) async {
      final mockResponse = http.Response(jsonEncode({
        'user': {'id': '12345'}
      }), 200);

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);

      SharedPreferences.setMockInitialValues({});
      when(mockSharedPreferences.setString('userId', '12345')).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      verify(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
      verify(mockSharedPreferences.setString('userId', '12345')).called(1);
      
      expect(find.text('Home Screen'), findsOneWidget); // Ensure we navigated to home screen
    });
  });
}
