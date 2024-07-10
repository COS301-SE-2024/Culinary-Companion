import 'package:flutter/material.dart';
import '../widgets/appliances_screen.dart';
import '../widgets/pantry_screen.dart';
import '../widgets/shopping_list_screen.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF20493C) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Shopping List'),
              Tab(text: 'Pantry'),
              Tab(text: 'Appliances'),
            ],
            labelColor: textColor,
            unselectedLabelColor: Color(0xFFDC945F),
            indicatorColor: textColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TabBarView(
          controller: _tabController,
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
