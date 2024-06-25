import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class SignUp3 extends StatefulWidget {
  final String fullName;
  final String dateOfBirth;
  final String bloodType;
  final String allergies;
  final String medication;
  final String phoneNumber;
  final String contactName;
  final String contactNumber;

  SignUp3({
    Key? key,
    required this.fullName,
    required this.dateOfBirth,
    required this.bloodType,
    required this.allergies,
    required this.medication,
    required this.phoneNumber,
    required this.contactName,
    required this.contactNumber,
  }) : super(key: key);

  @override
  _SignUp3State createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String errorMessage = '';

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'fullName': widget.fullName,
          'dateOfBirth': widget.dateOfBirth,
          'bloodType': widget.bloodType,
          'allergies': widget.allergies,
          'medication': widget.medication,
          'phoneNumber': widget.phoneNumber,
          'contactName': widget.contactName,
          'contactNumber': widget.contactNumber,
          'email': emailController.text,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              fullName: widget.fullName,
              userId: userCredential.user!.uid,
              isAuthenticated: true,
            ),
          ),
        );
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
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
        backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
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
                          WidgetSpan(child: SizedBox(height: 40)),
                          TextSpan(
                            text: "Step 3/3\n",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                          WidgetSpan(child: SizedBox(height: 20)),
                          TextSpan(
                            text: "Complete your registration",
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
                  _buildConfirmPasswordSection(context),
                  SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(226, 192, 68, 1),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: Size(250.0, 40.0),
                          ),
                          child: Text(
                            'Finish',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10), // Adjust padding to align text with input field
          child: Text(
            "Email",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10), // Add padding to narrow the width
          child: _buildTextFormField(
            controller: emailController,
            prefixIcon: Icon(Icons.email_outlined, color: Color.fromRGBO(226, 192, 68, 1)),
            hintText: "Enter email",
            obscureText: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10), // Adjust padding to align text with input field
          child: Text(
            "Password",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10), // Add padding to narrow the width
          child: _buildTextFormField(
            controller: passwordController,
            prefixIcon: Icon(Icons.password_outlined, color: Color.fromRGBO(226, 192, 68, 1)),
            hintText: "Enter password",
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10), // Adjust padding to align text with input field
          child: Text(
            "Confirm Password",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10), // Add padding to narrow the width
          child: _buildTextFormField(
            controller: confirmPasswordController,
            prefixIcon: Icon(Icons.password_outlined, color: Color.fromRGBO(226, 192, 68, 1)),
            hintText: "Confirm password",
            obscureText: true,
          ),
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
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color.fromRGBO(195, 195, 195, 1),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w300,
          ),
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
