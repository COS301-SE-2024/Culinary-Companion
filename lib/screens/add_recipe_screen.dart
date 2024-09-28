import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/form_screen.dart';
import '../widgets/help_add_recipe.dart';
import '../widgets/scan_recipe_screen.dart';
import '../widgets/paste_recipe_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _helpMenuOverlay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  late TabController _tabController;

  void _showHelpMenu() {
    _helpMenuOverlay = OverlayEntry(
      builder: (context) => HelpMenu(
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
            alignment: Alignment.centerRight, //aligns help button to the right
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Add Recipe PDF'),
                  Tab(text: 'Paste Recipe'),
                  Tab(text: 'Add with Form'),
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
          // Scan Recipe Screen
          ScanRecipe(),
          // Text Input Screen
          PasteRecipe(),
          // Form Screen
          RecipeForm(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddRecipeScreen(),
  ));
}