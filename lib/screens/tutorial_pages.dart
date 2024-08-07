import 'package:flutter/material.dart';
import '../widgets/desktop_tutorial.dart';
import '../widgets/mobile_tutorial.dart';

class TutorialPages extends StatefulWidget {
  @override
  _TutorialPagesState createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<TutorialPages>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;

  List<TutorialPage> _pages = [
    TutorialPage(
      title: "Welcome to Culinary Companion",
      description: "Embark on a delicious journey through your kitchen!",
      // icon: Icons.restaurant_menu,
      imagePath: 'welcome.png',
    ),
    TutorialPage(
      title: "Smart Pantry",
      description: "Effortlessly manage your ingredients and plan meals.",
      // icon: Icons.kitchen,
      imagePath: 'pantry.png',
    ),
    TutorialPage(
      title: "Intelligent Shopping",
      description: "Never forget an ingredient with our smart shopping list.",
      // icon: Icons.shopping_cart,
      imagePath: 'shopping.png',
    ),
    TutorialPage(
      title: "Appliance Tracking",
      description: "Find recipes that match your kitchen equipment.",
      // icon: Icons.food_bank_outlined,
      imagePath: 'appliances.png',
    ),
    TutorialPage(
      title: "Recipe Creator",
      description: "Share your culinary masterpieces with the world.",
      // icon: Icons.create,
      imagePath: 'recipes.png',
    ),
    TutorialPage(
      title: "Discover & Savour",
      description: "Explore, favorite, and cook with confidence!",
      // icon: Icons.favorite,
      imagePath: 'savour.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    // final theme = Theme.of(context);
    // final bool isLightTheme = theme.brightness == Brightness.light;
    final Color backgroundColor =  Color(0xFF283330); // Consistent dark green background

    return isMobile
        ? MobileTutorial(
            pageController: _pageController,
            pages: _pages,
            currentPage: _currentPage,
            backgroundColor: backgroundColor,
            goToHome: _goToHome,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _animationController.forward(from: 0);
            },
          )
        : DesktopTutorial(
            pageController: _pageController,
            pages: _pages,
            currentPage: _currentPage,
            backgroundColor: backgroundColor,
            goToHome: _goToHome,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _animationController.forward(from: 0);
            },
          );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final String imagePath;

  TutorialPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
