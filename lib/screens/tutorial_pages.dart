import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class TutorialPages extends StatefulWidget {
  @override
  _TutorialPagesState createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<TutorialPages> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;

  final Color _backgroundColor = Color(0xFF21493C); // Consistent dark green background

  List<TutorialPage> _pages = [
    TutorialPage(
      title: "Welcome to Culinary Companion",
      description: "Embark on a delicious journey through your kitchen!",
      icon: Icons.restaurant_menu,
    ),
    TutorialPage(
      title: "Smart Pantry",
      description: "Effortlessly manage your ingredients and plan meals.",
      icon: Icons.kitchen,
    ),
    TutorialPage(
      title: "Intelligent Shopping",
      description: "Never forget an ingredient with our smart shopping list.",
      icon: Icons.shopping_cart,
    ),
    TutorialPage(
      title: "Appliance Tracking",
      description: "Find recipes that match your kitchen equipment.",
      icon: Icons.food_bank_outlined,
    ),
    TutorialPage(
      title: "Recipe Creator",
      description: "Share your culinary masterpieces with the world.",
      icon: Icons.create,
    ),
    TutorialPage(
      title: "Discover & Savor",
      description: "Explore, favorite, and cook with confidence!",
      icon: Icons.favorite,
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
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _animationController.forward(from: 0);
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: TextButton(
                onPressed: _goToHome,
                child: Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                SizedBox(height: 20),
                _currentPage == _pages.length - 1
                    ? _buildGetStartedButton()
                    : _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: Duration(milliseconds: 500),
            child: Icon(
              page.icon,
              size: 200,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 40),
          FadeInUp(
            duration: Duration(milliseconds: 500),
            delay: Duration(milliseconds: 250),
            child: Text(
              page.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          FadeInUp(
            duration: Duration(milliseconds: 500),
            delay: Duration(milliseconds: 500),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                page.description,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List<Widget>.generate(
      _pages.length,
      (index) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: _currentPage == index ? 24 : 8,
        decoration: BoxDecoration(
          color: _currentPage == index ? Color(0xFFDC945F) : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "PREV",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Row(
              children: [
                Text(
                  "NEXT",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return ElasticIn(
      child: ElevatedButton(
        onPressed: _goToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDC945F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          elevation: 5,
        ),
        child: Text(
          "GET COOKING",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
