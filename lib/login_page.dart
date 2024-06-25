import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with StateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'https://www.googleapis.com/auth/user.birthday.read',
      ],
    );

    // Ensure the user is signed out before attempting a new sign-in
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

        if (!userData.exists) {
          // Fetch user's date of birth using People API
          try {
            final apiKey = 'YOUR_BROWSER_API_KEY'; // Replace with your API key
            final http.Client client = http.Client();

            final response = await client.get(
              Uri.parse(
                'https://people.googleapis.com/v1/people/me?personFields=birthdays&key=$apiKey',
              ),
              headers: {
                'Authorization': 'Bearer ${googleAuth.accessToken}',
              },
            );

            if (response.statusCode == 200) {
              final profile = json.decode(response.body);
              final birthday = profile['birthdays']?.first['date'];
              final formattedBirthday = birthday != null
                  ? '${birthday['day']}/${birthday['month']}/${birthday['year']}'
                  : null;

              if (!isDisposed) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpPage(
                      prefilledData: {
                        'fullName': user.displayName,
                        'email': user.email,
                        'phoneNumber': user.phoneNumber,
                        'dateOfBirth': formattedBirthday,
                      },
                      signUpMethod: 'Google',
                    ),
                  ),
                );
              }
            } else {
              throw Exception('Failed to fetch user data');
            }
          } catch (e) {
            print('Error fetching user data: $e');
            if (!isDisposed) {
              setState(() {
                errorMessage = 'Error fetching user data: $e';
              });
            }
          }
        } else {
          String fullName = userData['fullName'] ?? '';
          if (!isDisposed) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  fullName: fullName,
                  userId: user.uid,
                  isAuthenticated: true,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!isDisposed) {
        setState(() {
          errorMessage = 'An error occurred. Please try again. ${e.toString()}';
        });
      }
    }
  }

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        String fullName = userData.exists ? userData['fullName'] ?? '' : '';

        if (!isDisposed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                fullName: fullName,
                userId: user.uid,
                isAuthenticated: true,
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!isDisposed) {
        setState(() {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found for that email.';
              break;
            case 'wrong-password':
              errorMessage = 'Wrong password provided for that user.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is badly formatted.';
              break;
            case 'user-disabled':
              errorMessage = 'The user account has been disabled.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Try again later.';
              break;
            case 'invalid-credential':
              errorMessage = "Incorrect email or password";
              break;
            default:
              errorMessage = 'An unknown error occurred: ${e.message}';
          }
        });
      }
    } catch (e) {
      print("General exception: ${e.toString()}");
      if (!isDisposed) {
        setState(() {
          errorMessage = 'An error occurred. Please try again. ${e.toString()}';
        });
      }
    }
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(
          signUpMethod: 'Email',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset('assets/images/backArrow.png'),
            onPressed: () {
              Navigator.pop(context, 'from_login_page');
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 300.0,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 30, bottom: 0),
                            child: Text(
                              "Login\n",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                fontSize: 30.0,
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                            ),
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 30, top: 0),
                            child: Text(
                              "Login to continue using the application",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                                fontSize: 14.0,
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              _buildEmailSection(context),
              SizedBox(height: 20),
              _buildPasswordSection(context),
              SizedBox(height: 30.0),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, left: 50, right: 35),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Container(
                width: 200.0,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(226, 192, 68, 1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color.fromRGBO(226, 192, 68, 1)),
                ),
                child: OutlinedButton(
                  onPressed: signIn,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.transparent),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: Color.fromRGBO(37, 37, 37, 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 230.0,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await signInWithGoogle();

                      User? user = _auth.currentUser;

                      if (user != null) {
                        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

                        if (!userData.exists || userData.data() == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(
                                prefilledData: {
                                  'fullName': user.displayName,
                                  'email': user.email,
                                  'phoneNumber': user.phoneNumber,
                                  'dateOfBirth': dateOfBirthController.text,
                                },
                                signUpMethod: 'Google',
                              ),
                            ),
                          );
                        } else {
                          String fullName = userData.data().toString().contains('fullName') ? userData['fullName'] : '';
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                fullName: fullName,
                                userId: user.uid,
                                isAuthenticated: true,
                              ),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (!isDisposed) {
                        setState(() {
                          errorMessage = 'An error occurred. Please try again. ${e.toString()}';
                        });
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        height: 24.0,
                      ),
                      SizedBox(width: 12.0),
                      Text(
                        "Login with Google",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                          color: Color.fromRGBO(37, 37, 37, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: navigateToSignUp,
                child: Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 14.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        SizedBox(height: 10.0),
        _buildTextFormField(
          controller: emailController,
          prefixIcon: Icon(Icons.email_outlined, color: Color.fromRGBO(226, 192, 68, 1)),
          hintText: "Enter email",
          obscureText: false,
        ),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        SizedBox(height: 10.0),
        _buildTextFormField(
          controller: passwordController,
          prefixIcon: Icon(Icons.password_outlined, color: Color.fromRGBO(226, 192, 68, 1)),
          hintText: "Enter password",
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? prefixIcon,
  }) {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Color.fromRGBO(195, 195, 195, 1), fontFamily: 'Roboto', fontWeight: FontWeight.w300),
          filled: true,
          fillColor: Color.fromARGB(255, 87, 89, 127),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Color.fromARGB(255, 87, 89, 127)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: const Color.fromARGB(255, 33, 215, 243)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }
}

mixin StateMixin<T extends StatefulWidget> on State<T> {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
