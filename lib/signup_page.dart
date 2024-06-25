import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_page2.dart';

class SignUpPage extends StatefulWidget {
  final Map<String, dynamic>? prefilledData;
  final String signUpMethod;

  SignUpPage({this.prefilledData, required this.signUpMethod});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController bloodTypeController = TextEditingController();
  TextEditingController allergiesController = TextEditingController();
  TextEditingController medicationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefilledData != null) {
      fullNameController.text = widget.prefilledData?['fullName'] ?? '';
      emailController.text = widget.prefilledData?['email'] ?? '';
      phoneNumberController.text = widget.prefilledData?['phoneNumber'] ?? '';
      dateOfBirthController.text = widget.prefilledData?['dateOfBirth'] ?? '';
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUp2(
            fullName: fullNameController.text,
            dateOfBirth: dateOfBirthController.text,
            bloodType: bloodTypeController.text,
            allergies: allergiesController.text,
            medication: medicationController.text,
            phoneNumber: phoneNumberController.text,
            signUpMethod: widget.signUpMethod,
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dateOfBirthController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
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
                            text: "Step 1/3\n",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                          WidgetSpan(child: SizedBox(height: 20)),
                          TextSpan(
                            text: "Enter your personal information",
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
                  _buildFullNameSection(context),
                  SizedBox(height: 20),
                  _buildDateOfBirthSection(context),
                  SizedBox(height: 20),
                  _buildPhoneNumberSection(context),
                  SizedBox(height: 20),
                  _buildBloodTypeSection(context),
                  SizedBox(height: 20),
                  _buildAllergiesSection(context),
                  SizedBox(height: 20),
                  _buildCurrentMedicationSection(context),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () => signUp(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(226, 192, 68, 1),
                            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: Size(250.0, 40.0),
                          ),
                          child: Text('Continue', style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            fontSize: 16.0,
                            color: Color.fromRGBO(37, 37, 37, 1),
                          )),
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

  Widget _buildFullNameSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Full Name *",
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
                controller: fullNameController,
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
                  hintText: 'Enter full name',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1), 
                    fontFamily: 'Roboto', 
                    fontWeight: FontWeight.w300
                  ),
                ),
                style: TextStyle(color: Colors.white), // Set the entered text color to white
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
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

  Widget _buildDateOfBirthSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Date of Birth *",
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
              width: 200,
              child: InkWell(
                onTap: () => _selectDate(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: dateOfBirthController,
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
                      hintText: 'dd/mm/yyyy',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(195, 195, 195, 1),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                      suffixIcon: Icon(Icons.calendar_today, color: Color.fromRGBO(226, 192, 68, 1)),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of birth is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Blood Type ",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 231, 255, 249),
                    ),
                  ),
                  TextSpan(
                    text: "(not required)",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                      fontSize: 12.0,
                      color: Color.fromARGB(255, 231, 255, 249),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              width: 200,
              child: DropdownButtonFormField<String>(
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
                hint: Text(
                  'Select blood type',
                  style: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                iconEnabledColor: Color.fromRGBO(226, 192, 68, 1),
                iconDisabledColor: Colors.grey,
                style: TextStyle(color: Colors.black),
                selectedItemBuilder: (BuildContext context) {
                  return <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map<Widget>((String value) {
                    return Text(
                      value,
                      style: TextStyle(color: Colors.white),
                    );
                  }).toList();
                },
                items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  bloodTypeController.text = newValue!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Allergies ",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 231, 255, 249),
                    ),
                  ),
                  TextSpan(
                    text: "(not required)",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                      fontSize: 10.0,
                      color: Color.fromARGB(255, 231, 255, 249),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              width: double.infinity,
              child: TextField(
                controller: allergiesController,
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
                  hintText: 'Enter allergies',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Current Medication ",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 231, 255, 249),
                    ),
                  ),
                  TextSpan(
                    text: "(not required)",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                      fontSize: 10.0,
                      color: Color.fromARGB(255, 231, 255, 249),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Container(
              width: double.infinity,
              child: TextField(
                controller: medicationController,
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
                  hintText: 'Enter current medication',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Phone Number *",
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
                controller: phoneNumberController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
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
                  hintText: 'Enter phone number',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(195, 195, 195, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Enter a valid phone number';
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
}
