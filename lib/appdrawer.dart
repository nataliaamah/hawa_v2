import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hawa_v1/login_page.dart';
import 'about_us.dart';
import 'contact_us.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:hawa_v1/contact_emergency.dart';
import 'home_page.dart';


class AppDrawer extends StatelessWidget {
  final bool isAuthenticated;
  final String userId;

  AppDrawer({required this.isAuthenticated, required this.userId});

  Future<String?> _fetchPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc['phoneNumber'];
    }
    return null;
  }

  Future<DocumentSnapshot?> _fetchFullName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc : null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 45, 45, 45),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 30),
          ListTile(
            contentPadding: EdgeInsets.only(left: 230),
            leading: Icon(Icons.close_rounded, size: 30, color: Color.fromRGBO(255, 255, 255, 1)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 100),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('Emergency Alerts', style: TextStyle(fontSize: 20, color: Color.fromRGBO(248, 51, 60, 1), fontWeight: FontWeight.w800)),
            onTap: () async {
              if (isAuthenticated) {
                final phoneNumber = await _fetchPhoneNumber();
                if (phoneNumber != null) {
                  final fullName = await _fetchFullName(userId);
                  if (fullName != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactEmergencyPage(
                          phoneNumber: phoneNumber,
                          fullName: fullName['fullName'],
                          userId: userId,
                          isAuthenticated: isAuthenticated,
                        ),
                      ),
                    ).then((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(isAuthenticated: isAuthenticated, fullName: fullName['fullName'], userId: userId)),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Full name not found'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone number not found'),
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Feature Locked'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('This feature is locked.'),
                            Text('Please log in or sign up to access it.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Login'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage())).then((value) {
                              // Check if the user is authenticated after the login page returns
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context).pop(); // Close the dialog
                              }
                            });
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('About Us', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('Contact Us', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsPage()));
            },
          ),
          SizedBox(height: 250),
          ListTile(
            leading: Icon(Icons.logout_rounded, size: 25, color: Color.fromRGBO(255, 255, 255, 1)),
            contentPadding: EdgeInsets.only(left: 50),
            title: Text(
              isAuthenticated ? 'Logout' : 'Login/Sign Up',
              style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1)),
            ),
            onTap: () {
              if (isAuthenticated) {
                // Sign out the user
                FirebaseAuth.instance.signOut().then((_) {
                  // Navigate to HomePage with limited functionalities
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(isAuthenticated: false, fullName: 'Guest', userId: '')),
                    (route) => false, // Remove all previous routes
                  );
                });
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              }
            },
          ),
        ],
      ),
    );
  }
}
