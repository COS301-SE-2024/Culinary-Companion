import 'package:flutter/material.dart';
import '../widgets/generate_meal_plan_screen.dart';
import '../widgets/my_meal_plans_screen.dart';
import '../widgets/help_meal_planner.dart';

class MealPlannerScreen extends StatefulWidget {
  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _helpMenuOverlay;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showHelpMenu() {
    _helpMenuOverlay = OverlayEntry(
      builder: (context) => HelpMealPlanner(
        onClose: () {
          _helpMenuOverlay?.remove();
          _helpMenuOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_helpMenuOverlay!);
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
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Generate My Meal Plan'),
                  Tab(text: 'My Meal Plans'),
                ],
                labelColor: textColor,
                unselectedLabelColor: Color(0xFFDC945F),
                indicatorColor: textColor,
              ),
              Positioned(
                right: 20,
                bottom: 5,
                child: IconButton(
                  icon: Icon(Icons.help),
                  onPressed: _showHelpMenu,
                  iconSize: 35,
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pass the TabController to the GenerateMealPlanScreen
          GenerateMealPlanScreen(tabController: _tabController),
          MyMealPlansScreen(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MealPlannerScreen(),
  ));
}
