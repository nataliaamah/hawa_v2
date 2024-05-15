import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Onboarding extends StatelessWidget {
  final VoidCallback onCompleted;

  const Onboarding({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Onboarding')),
        body: OnboardingScreen(onCompleted: onCompleted),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children: <Widget>[
            buildOnboardingOne(context),
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
    // Your implementation here
    return false;
  }

  Widget buildOnboardingOne(BuildContext context) {
    // Your implementation here
    return Container();
  }
}
