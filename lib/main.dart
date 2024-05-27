import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hawa_v1/onboarding.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:hawa_v1/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboard = prefs.getBool('seenOnboard') ?? false;
  runApp(HawaApp(seenOnboard: seenOnboard));
}

class HawaApp extends StatefulWidget {
  @override
  _HawaAppState createState() => _HawaAppState();
  final bool seenOnboard;
  const HawaApp({Key? key, required this.seenOnboard}) : super(key: key);
}

class _HawaAppState extends State<HawaApp> {
  bool _seenOnboard = false;
  String? fullName;
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkOnboardStatus();
    _fetchUserData();
  }

  Future<void> _checkOnboardStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboard = prefs.getBool('seenOnboard');
    setState(() {
      _seenOnboard = seenOnboard ?? false;
    });
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        fullName = userData['fullName'];
        userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawa v1',
      home: _seenOnboard
          ? (FirebaseAuth.instance.currentUser != null && fullName != null
              ? HomePage(fullName: fullName!, userId: userId!)
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
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
    );
  }
}
