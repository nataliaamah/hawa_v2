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
            buildOnboardingThree(context),
            buildOnboardingFour(context),
            // Add other onboarding pages here
          ],
        ),
        if (_currentPageIndex < 4)
          _rightButton()
        else if (_currentPageIndex > 0)
          _leftButton()
        /*if (_currentPageIndex == 4) // assuming the last page index is 3
          ElevatedButton(
            onPressed: widget.onCompleted, 
            child: Text('Complete Onboarding'),
          ),*/
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

// first onboarding
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
            style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Spacer(flex: 37),
          SizedBox(height: 30),
          SizedBox(
            height: 40,
            child: SmoothPageIndicator(
                  controller : _pageViewController,
                  count: 4,
                  effect: WormEffect(
                    activeDotColor: Color(0xFF9CE1CF),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  // second onboarding
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
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 10),
            Image.asset('assets/images/location_onboard.png', height: 200, width: 200),
            SizedBox(height:10),
            Text(
              "Hawa allows you to share your current location with trusted contacts from the app.",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
            ),
            Spacer(flex: 2),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20), // Adjust padding as needed
              child: SizedBox(
                height: 10,
                child: SmoothPageIndicator(
                  controller : _pageViewController,
                  count: 4,
                  effect: WormEffect(
                    activeDotColor: Color(0xFF9CE1CF),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
            ),
          ]
        )
      ),
      );
  }

  Widget buildOnboardingThree(BuildContext context){
    return SafeArea(
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 51, vertical: 92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 1),
            Text(
              "Capture Your Surroundings",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 10),
            Image.asset('assets/images/snap_onboard.png', height: 200, width: 200),
            SizedBox(height:10),
            Text(
              "Share images of your surroundings to your designated emergency contact.",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
            ),
            Spacer(flex: 2),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20), // Adjust padding as needed
              child: SizedBox(
                height: 10,
                child: SmoothPageIndicator(
                  controller : _pageViewController,
                  count: 4,
                  effect: WormEffect(
                    activeDotColor: Color(0xFF9CE1CF),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
            ),
          ]
        )
      ),
      );
  }

  Widget buildOnboardingFour(BuildContext context){
    return SafeArea(
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.symmetric(horizontal: 51, vertical: 92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 1),
            Text(
              "Emergency Calls",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 10),
            Image.asset('assets/images/emergency_onboard.png', height: 200, width: 200),
            SizedBox(height:10),
            Text(
              "Initiate a call to your emergency contact directly from the app, ensuring quick access to assistance in times of distress.",
              style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
            ),
            Spacer(flex: 2),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: 10,
                child: SmoothPageIndicator(
                  controller : _pageViewController,
                  count: 4,
                  effect: WormEffect(
                    activeDotColor: Color(0xFF9CE1CF),
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
            ),
          ]
        )
      ),
      );
  }

  
  Row _leftButton() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () {
          setState(() {
              _currentPageIndex -= 1;
          });
          _pageViewController.animateToPage(
            _currentPageIndex,
            duration: Duration(milliseconds: 300), // Sets duration to 300 milliseconds
            curve: Curves.easeInOut);
        },
        child: 
        Padding(
          padding: EdgeInsets.only(bottom: 60, left:50),
          child: Image.asset('assets/images/nextArrow.png', height: 30, width: 30,),
          )
      ),
    ],
  );
  }
  
  // arrow next
  Row _rightButton() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () {
          setState(() {
            if(_currentPageIndex < 4)
              _currentPageIndex += 1;
          });
          _pageViewController.animateToPage(
            _currentPageIndex,
            duration: Duration(milliseconds: 300), // Sets duration to 300 milliseconds
            curve: Curves.easeInOut);
        },
        child: 
        Padding(
          padding: EdgeInsets.only(bottom: 60, left:250),
          child: Image.asset('assets/images/nextArrow.png', height: 30, width: 30,),
          )
      ),
    ],
  );
}
}

