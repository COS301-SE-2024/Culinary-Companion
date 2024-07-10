import 'package:flutter/material.dart';
import '../widgets/appliances_screen.dart';
import '../widgets/pantry_screen.dart';
import '../widgets/shopping_list_screen.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inventory'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Shopping List'),
              Tab(text: 'Pantry'),
              Tab(text: 'Appliances'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ShoppingListScreen(),
            PantryScreen(),
            AppliancesScreen(),
          ],
        ),
      ),
    );
  }
}
