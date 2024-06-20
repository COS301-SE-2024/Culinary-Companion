import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Signup Page', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Signup with Valid Credentials', () async {
      final emailField = find.byValueKey('emailField');
      final passwordField = find.byValueKey('passwordField');
      final confirmPasswordField = find.byValueKey('confirmPasswordField');
      final signupButton = find.byValueKey('signupSubmitButton');

      await driver.tap(emailField);
      await driver.enterText('test@example.com');
      await driver.tap(passwordField);
      await driver.enterText('password123');
      await driver.tap(confirmPasswordField);
      await driver.enterText('password123');
      await driver.tap(signupButton);

      // Add assertions based on expected behavior after signup
      await driver.waitFor(find.text('Confirm Details')); // Example assertion
    });
  });
}
