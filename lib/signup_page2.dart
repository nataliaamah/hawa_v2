import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hawa_v1/firebase_service.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:hawa_v1/login_page.dart';

class SignUp2 extends StatefulWidget {
  final String fullName;
  final String dateOfBirth;
  final String bloodType;
  final String allergies;
  final String medication;

  SignUp2({
    Key? key,
    required this.fullName,
    required this.dateOfBirth,
    required this.bloodType,
    required this.allergies,
    required this.medication,
  }) : super(key: key);

  @override
  _SignUp2State createState() => _SignUp2State();
}

class _SignUp2State extends State<SignUp2> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyPasswordController = TextEditingController();

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text == verifyPasswordController.text) {
        Map<String, dynamic> userData = {
          'fullName': widget.fullName,
          'dateOfBirth': widget.dateOfBirth,
          'bloodType': widget.bloodType,
          'allergies': widget.allergies,
          'medication': widget.medication,
          'email': emailController.text,
        };

        FirebaseService firebaseService = FirebaseService();
        try {
          await firebaseService.signUpWithEmail(emailController.text, passwordController.text, userData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up Successful!')),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(title: "Home",)));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up failed: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/backArrow.png',
                      height: 32,
                      width: 32,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Register\n",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 30.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                          WidgetSpan(
                              child: Text("\n"),
                              style: TextStyle(fontSize: 10)),
                          TextSpan(
                            text: "Enter your account information",
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
                  SizedBox(height: 20),
                  _buildEmailSection(context),
                  SizedBox(height: 20),
                  _buildPasswordSection(context),
                  SizedBox(height: 20),
                  _buildVerifyPasswordSection(context),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9CE1CF),
                            foregroundColor:
                                const Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: Size(250.0, 40.0),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: Color.fromRGBO(37, 37, 37, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Email *",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
                color: Color.fromARGB(255, 231, 255, 249),
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              width: double.infinity,
              child: TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 52, 81, 82),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 52, 81, 82)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Enter email',
                  hintStyle: TextStyle(
                      color: Color.fromRGBO(195, 195, 195, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Password *",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
                color: Color.fromARGB(255, 231, 255, 249),
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              width: double.infinity,
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 52, 81, 82),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 52, 81, 82)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Enter password',
                  hintStyle: TextStyle(
                      color: Color.fromRGBO(195, 195, 195, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyPasswordSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Verify Password *",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
                color: Color.fromARGB(255, 231, 255, 249),
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              width: double.infinity,
              child: TextFormField(
                controller: verifyPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 52, 81, 82),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 52, 81, 82)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Verify password',
                  hintStyle: TextStyle(
                      color: Color.fromRGBO(195, 195, 195, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Verify password is required';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void backToLogin(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
