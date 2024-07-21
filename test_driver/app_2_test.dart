import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Culinary Companion App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test('Verify navbar items', () async {
      // Wait for the app to load
      await driver.waitFor(find.text('Home'));

      // Verify navbar items
      expect(await driver.getText(find.text('Home')), 'Home');
      expect(await driver.getText(find.text('Add Recipe')), 'Add Recipe');
      expect(await driver.getText(find.text('Shopping List')), 'Shopping List');
      expect(await driver.getText(find.text('Pantry')), 'Pantry');
      expect(await driver.getText(find.text('Appliances')), 'Appliances');
      expect(await driver.getText(find.text('Favorite Recipes')),
          'Favorite Recipes');
      expect(await driver.getText(find.text('Profile')), 'Profile');
    });
    test('Navigate to Pantry screen', () async {
      // Tap on the Pantry item in the navbar
      await driver.tap(find.byValueKey(('Pantry')));
      // Verify that we're on the Pantry screen
      //expect(await driver.getText(find.text('Pantry')), 'Pantry');
      await driver.waitFor(find.byValueKey('Pantry'));
    });
    test('Open and close Pantry help menu', () async {
      await driver.tap(find.byType('IconButton'));
      await driver.waitFor(find.byType('HelpMenu'));
      await driver.tap(find.byValueKey('close_help_menu'));
      await driver.waitForAbsent(find.byType('HelpMenu'));
    });
    test('Navigate to Appliances screen', () async {
      // Tap on the Appliances navigation item
      await driver.tap(find.byValueKey('Appliances'));

      // Verify that we're on the Appliances screen by checking for the add button
      await driver.waitFor(find.byValueKey('add_appliance_button'));
    });

    test('Verify empty state message', () async {
      await driver.waitFor(find.text(
          "No appliances have been added. Click the plus icon to add your first appliance!"));
    });

    test('Open and close appliance help menu', () async {
      await driver.tap(find.byType('IconButton'));
      await driver.waitFor(find.byType('HelpMenu'));
      await driver.tap(find.byValueKey('close_help_menu'));
      await driver.waitForAbsent(find.byType('HelpMenu'));
    });

    test('Navigate to Shopping List screen', () async {
      // Tap on the Appliances navigation item
      await driver.tap(find.byValueKey('Shopping List'));

      // Verify that we're on the Appliances screen by checking for the add button
      await driver.waitFor(find.byValueKey('add_shopping_list_button'));
    });
    test('Open and close Shopping List help menu', () async {
      await driver.tap(find.byType('IconButton'));
      await driver.waitFor(find.byType('HelpMenu'));
      await driver.tap(find.byValueKey('close_help_menu'));
      await driver.waitForAbsent(find.byType('HelpMenu'));
    });

    // test('Navigate to Add Recipe screen', () async {
    //   // Tap on the Appliances navigation item
    //   await driver.tap(find.byValueKey('Add Recipe'));

    //   // Verify that we're on the Appliances screen by checking for the add button
    //   await driver.waitFor(find.byValueKey('recipe_button'));
    // });
  });
}
