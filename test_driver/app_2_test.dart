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
    test('Navigate to Appliances screen', () async {
      // Tap on the Appliances navigation item
      await driver.tap(find.byValueKey('Appliances'));

      // Verify that we're on the Appliances screen by checking for the add button
      await driver.waitFor(find.byValueKey('add_appliance_button'));
    });

    test('Navigate to Shopping List screen', () async {
      // Tap on the Appliances navigation item
      await driver.tap(find.byValueKey('Shopping List'));

      // Verify that we're on the Appliances screen by checking for the add button
      await driver.waitFor(find.byValueKey('add_shopping_list_button'));
    });



    //     test('Navigate to ShoppingList screen', () async {
    //   // Tap on the Pantry item in the navbar
    //   await driver.tap(find.byValueKey(('ShoppingList')));
    //   // Verify that we're on the Pantry screen
    //   //expect(await driver.getText(find.text('Pantry')), 'Pantry');
    //   await driver.waitFor(find.text('Shopping List'));
    // });
  });
}
