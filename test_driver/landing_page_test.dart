import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Landing Page', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Navigate to Login Screen', () async {
      final loginButton = find.byValueKey('loginButton');
      await driver.tap(loginButton);
      await driver.waitFor(find.text('Welcome Back!'));
    });

    test('Navigate to Signup Screen', () async {
      final signupButton = find.byValueKey('signupButton');
      await driver.tap(signupButton);
      await driver.waitFor(find.text('Create an account'));
    });
  });
}
