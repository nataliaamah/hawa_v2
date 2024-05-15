import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawa_v1/onboarding.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:hawa_v1/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboard = prefs.getBool('seenOnboard') ?? false;
  runApp(HawaApp(seenOnboard: seenOnboard));
}

class HawaApp extends StatefulWidget {
  @override
  _HawaAppState createState() => _HawaAppState();
  final bool seenOnboard;
  const HawaApp({super.key, required this.seenOnboard});
}

class _HawaAppState extends State<HawaApp> {
  bool _seenOnboard = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardStatus();
  }

  Future<void> _checkOnboardStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboard = prefs.getBool('seenOnboard');
    setState(() {
      _seenOnboard = seenOnboard ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawa v1',
      home: _seenOnboard
          ? (FirebaseAuth.instance.currentUser != null
              ? const HomePage(title: 'Hawa')
              : LoginPage())
          : Onboarding(
              onCompleted: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seenOnboard', true);
                setState(() {
                  _seenOnboard = true;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage(title: 'Hawa')),
                );
              },
            ),
    );
  }
}
