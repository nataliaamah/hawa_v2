import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatelessWidget {
  final VoidCallback onCompleted;

  const Onboarding({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingScreen(onCompleted: onCompleted),
      ),
      theme : ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 10, 38, 39),
        )
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

// build pageview
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children: [
            buildOnboardingOne(context),
            buildOnboardingTwo(context),
            // Add other onboarding pages here
          ],
        ),
        if (_currentPageIndex == 3) // assuming the last page index is 3
          ElevatedButton(
            onPressed: widget.onCompleted, 
            child: Text('Complete Onboarding'),
          ),
      ],
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  bool _isOnDesktopAndWeb() {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return true;
      default:
        return false;
    }
  }

// build page 1
  Widget buildOnboardingOne(BuildContext context) {
    return SafeArea(
    child: Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 51, vertical: 92),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 10),
          Image.asset('assets/images/hawa_logo.png', height: 300, width: 400),
          Text(
            "Your Guardian in Times of Need",
            style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400,),
          ),
          Spacer(flex: 37),
          SizedBox(height: 30),
          SizedBox(
            height: 40,
            child: AnimatedSmoothIndicator(
              activeIndex: 0,
              count: 2,
              effect: ScrollingDotsEffect(
                activeDotColor: Color(0xFF9CE1CF),
                dotHeight: 15,
              ),
            ),
          ),
          
          
        ],
      ),
    ),
  );
  }

  Widget buildOnboardingTwo(BuildContext context){
    return SafeArea(
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 51, vertical: 92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 1),
            Text(
              "Share Your Location",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10),
            Image.asset('assets/images/location_onboard.png', height: 200, width: 200),
            SizedBox(height:10),
            Text(
              "Share your location to emergency contact.",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
            ),
            Spacer(flex: 2),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20), // Adjust padding as needed
              child: SizedBox(
                height: 10,
                child: AnimatedSmoothIndicator(
                  activeIndex: 1,
                  count: 2,
                  effect: ScrollingDotsEffect(
                    activeDotColor: Color(0xFF9CE1CF),
                    dotHeight: 15,
                  ),
                ),
              ),
            ),
          ]
        )
      ),
      );
  }
}


