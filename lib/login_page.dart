import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hawa_v1/home_page.dart';

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(title: "Home Page")),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorMessage = 'Wrong password provided for that user.';
        });
      } else {
        setState(() {
          errorMessage = 'An unknown error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Change to sign up page later
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50.0),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 200.0,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Login\n",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 24.0,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                        TextSpan(
                          text: "Login to continue using the application",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            fontSize: 14.0,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              _buildEmailSection(context),
              SizedBox(height: 20.0),
              _buildPasswordSection(context),
              SizedBox(height: 20.0),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              GestureDetector(
                onTap: signIn,
                child: Text(
                  "Sign in",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
              GestureDetector(
                onTap: navigateToSignUp,
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    color: Color.fromRGBO(168, 179, 248, 1),
                  ),
                ),
              ),
              Spacer(),
              Container(
                width: 250.0,
                child: OutlinedButton(
                  onPressed: signIn,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color.fromRGBO(255, 255, 255, 1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10.0),
        _buildTextFormField(
          controller: emailController,
          hintText: "Enter your email",
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10.0),
        _buildTextFormField(
          controller: passwordController,
          hintText: "Enter your password",
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
