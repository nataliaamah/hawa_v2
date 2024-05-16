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
            Text('Testing'),
            // Add other onboarding pages here
          ],
        ),
        if (_currentPageIndex == 3) // assuming the last page index is 3
          ElevatedButton(
            onPressed: widget.onCompleted, // Invoke the onCompleted callback
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
          Spacer(flex: 32),
          Image.asset('assets/images/1.png', height: 300, width: 400),
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
                activeDotColor: Color(0X1212121D),
                dotHeight: 30,
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
            Spacer(),
            Text(
              "Share Your Location",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400,),
            ),
            SizedBox(height : 30),
            Image.asset('assets/images/1.png', height : 300, width: 300,),
            
          ]
        )
      ),
      );
  }
}


