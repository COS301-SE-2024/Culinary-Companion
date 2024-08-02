import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../screens/tutorial_pages.dart';

class MobileTutorial extends StatelessWidget {
  final PageController pageController;
  final List<TutorialPage> pages;
  final int currentPage;
  final Color backgroundColor;
  final VoidCallback goToHome;
  final ValueChanged<int> onPageChanged;

  MobileTutorial({
    required this.pageController,
    required this.pages,
    required this.currentPage,
    required this.backgroundColor,
    required this.goToHome,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: pages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return _buildPage(pages[index]);
            },
          ),
          Positioned(
            top: 20,
            right: 10,
            child: SafeArea(
              child: TextButton(
                onPressed: goToHome,
                child: Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                SizedBox(height: 10),
                currentPage == pages.length - 1
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
            child: Image.asset(
              page.imagePath,
              width: 150,
              height: 150,
            ),
          ),
          SizedBox(height: 20),
          FadeInUp(
            duration: Duration(milliseconds: 500),
            delay: Duration(milliseconds: 250),
            child: Text(
              page.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          FadeInUp(
            duration: Duration(milliseconds: 500),
            delay: Duration(milliseconds: 500),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                page.description,
                style: TextStyle(
                  fontSize: 16,
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
      pages.length,
      (index) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 3),
        height: 6,
        width: currentPage == index ? 20 : 6,
        decoration: BoxDecoration(
          color: currentPage == index
              ? Color(0xFFDC945F)
              : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  "PREV",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Row(
              children: [
                Text(
                  "NEXT",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
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
        onPressed: goToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDC945F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          elevation: 5,
        ),
        child: Text(
          "GET COOKING",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
