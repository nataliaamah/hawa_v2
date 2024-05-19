import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:hawa_v1/signup_page.dart';

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
  } catch (e) {
    print("General exception: ${e.toString()}");
    setState(() {
      errorMessage = 'An error occurred. Please try again. ${e.toString()}';
    });
  }
}

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUp()), // Change to sign up page later
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
              SizedBox(height: 30.0),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 300.0,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child : Padding(
                            padding:EdgeInsets.only(left: 50, bottom: 0),
                            child :
                              Text( "Login\n", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 30.0, color: Color.fromRGBO(255, 255, 255, 1),)
                            )
                            ),
                          ),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 50, top: 0),
                            child: Text("Login to continue using the application", style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w300, fontSize: 14.0, color: Color.fromRGBO(255, 255, 255, 1),)
                          )
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              _buildEmailSection(context),
              SizedBox(height: 5.0),
              _buildPasswordSection(context),
              SizedBox(height: 30.0),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, left: 50, right: 35),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              GestureDetector(
                onTap: navigateToSignUp,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: Color.fromRGBO(198, 205, 250, 1),
                    color: Color.fromRGBO(198, 205, 250, 1),
                  ),
                ),
              ),
              Spacer(),
              Container(
                width: 250.0,
                decoration: BoxDecoration(
                  color: Color(0xFF9CE1CF), 
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Color.fromARGB(255, 122, 185, 168)), 
                ),
                child: OutlinedButton(
                  onPressed: signIn,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
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
            ]
            ),
        )
        ),
      );
    }
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10.0),
        _buildTextFormField(
          controller: passwordController,
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
  }) {
    return SizedBox(
      width: 300.0,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:TextStyle(color:Color.fromRGBO(127, 127, 127, 1), fontFamily: 'Roboto', fontWeight: FontWeight.w300),
          filled: true,
          fillColor: Color.fromRGBO(255, 255, 255, 1),
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
