import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../screens/tutorial_pages.dart';

Color getFontColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.light
      ? Color(0xFF283330)
      : Color(0XFFEDEDED);
}

class DesktopTutorial extends StatelessWidget {
  final PageController pageController;
  final List<TutorialPage> pages;
  final int currentPage;
  final Color backgroundColor;
  final VoidCallback goToHome;
  final ValueChanged<int> onPageChanged;

  DesktopTutorial({
    required this.pageController,
    required this.pages,
    required this.currentPage,
    required this.backgroundColor,
    required this.goToHome,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fontColor = getFontColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: pages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return _buildPage(pages[index], context);
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: TextButton(
                onPressed: goToHome,
                child: Text(
                  "SKIP",
                  style: TextStyle(
                    color: fontColor,
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
                currentPage == pages.length - 1
                    ? _buildGetStartedButton()
                    : _buildNavigationButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page, BuildContext context) {
    final fontColor = getFontColor(context);
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: Duration(milliseconds: 500),
            child: Image.asset(
              page.imagePath,
              width: 200,
              height: 200,
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
                color: fontColor,
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
                  color: fontColor,
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
        margin: EdgeInsets.symmetric(horizontal: 4),
        height: 8,
        width: currentPage == index ? 24 : 8,
        decoration: BoxDecoration(
          color: currentPage == index
              ? Color(0xFFDC945F)
              : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final fontColor = getFontColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
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
                Icon(Icons.arrow_back_ios, color: fontColor, size: 18),
                SizedBox(width: 8),
                Text(
                  "PREV",
                  style: TextStyle(color: fontColor, fontSize: 16),
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
                  style: TextStyle(color: fontColor, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: fontColor, size: 18),
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
