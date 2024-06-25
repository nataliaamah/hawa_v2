import 'package:flutter/material.dart';
import 'signup_page3.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class SignUp2 extends StatefulWidget {
  final String fullName;
  final String dateOfBirth;
  final String bloodType;
  final String allergies;
  final String medication;
  final String phoneNumber;
  final String signUpMethod;

  SignUp2({
    Key? key,
    required this.fullName,
    required this.dateOfBirth,
    required this.bloodType,
    required this.allergies,
    required this.medication,
    required this.phoneNumber,
    required this.signUpMethod,
  }) : super(key: key);

  @override
  _SignUp2State createState() => _SignUp2State();
}

class _SignUp2State extends State<SignUp2> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  String _relationship = 'Parent';

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.fullName;
    dateOfBirthController.text = widget.dateOfBirth;
    bloodController.text = widget.bloodType;
    allergiesController.text = widget.allergies;
    medicationController.text = widget.medication;
    phoneNumberController.text = widget.phoneNumber;
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (widget.signUpMethod == 'Google') {
        // Save data to Firestore
        try {
          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).set({
            'fullName': fullNameController.text,
            'dateOfBirth': dateOfBirthController.text,
            'bloodType': bloodController.text,
            'allergies': allergiesController.text,
            'currentMedication': medicationController.text,
            'phoneNumber': phoneNumberController.text,
            'contactName': contactNameController.text,
            'contactNumber': contactNumberController.text,
            'relationship': _relationship,
            'email': FirebaseAuth.instance.currentUser?.email,
            'uid': FirebaseAuth.instance.currentUser?.uid,
            'signUpMethod': 'Google',
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                fullName: fullNameController.text,
                userId: FirebaseAuth.instance.currentUser!.uid,
                isAuthenticated: true,
              ),
            ),
          );
        } catch (e) {
          setState(() {
            _autoValidate = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving data: $e')),
          );
        }
      } else {
        // Navigate to SignUp3 for traditional email sign-ups
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUp3(
              fullName: fullNameController.text,
              dateOfBirth: dateOfBirthController.text,
              bloodType: bloodController.text,
              allergies: allergiesController.text,
              medication: medicationController.text,
              phoneNumber: phoneNumberController.text,
              contactName: contactNameController.text,
              contactNumber: contactNumberController.text,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

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
                            text: "Step 2/3\n",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                          WidgetSpan(child: SizedBox(height: 20)),
                          TextSpan(
                            text: "Enter your emergency contact information",
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
                  _buildContactNameSection(context),
                  SizedBox(height: 20),
                  _buildContactNumberSection(context),
                  SizedBox(height: 20),
                  _buildRelationshipSection(context),
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
                            backgroundColor: Color.fromRGBO(226, 192, 68, 1),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: Size(250.0, 40.0),
                          ),
                          child: Text(
                            'Continue',
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

  Widget _buildContactNameSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Contact Name *",
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
                controller: contactNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 87, 89, 127),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color.fromARGB(255, 87, 89, 127)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Enter contact name',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact name is required';
                  }
                  return null;
                },
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactNumberSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Contact Number *",
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
                controller: contactNumberController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 87, 89, 127),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color.fromARGB(255, 87, 89, 127)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  hintText: 'Enter contact number',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact number is required';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Enter a valid contact number';
                  }
                  return null;
                },
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Relationship *",
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
              child: DropdownButtonFormField<String>(
                value: _relationship,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 87, 89, 127),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color.fromARGB(255, 87, 89, 127)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.white), // Style for the selected item text
                items: <String>['Parent', 'Sibling', 'Close Friend', 'Children']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)), // Style for the dropdown items
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _relationship = newValue!;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return <String>['Parent', 'Sibling', 'Close Friend', 'Children'].map<Widget>((String value) {
                    return Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
