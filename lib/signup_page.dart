import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hawa_v1/signup_page3.dart';
import 'package:intl/intl.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:hawa_v1/login_page.dart';
import 'package:hawa_v1/signup_page2.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>{
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      dateOfBirthController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
    }
  }
  
  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp2(
        fullName : fullNameController.text,
        dateOfBirth : dateOfBirthController.text,
        bloodType: bloodController.text,
        allergies: allergiesController.text,
        medication: medicationController.text,
      )),);
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
                          WidgetSpan(child: SizedBox(height: 40)), // Add space
                          TextSpan(
                            text: "Step 1/3\n",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                          WidgetSpan(child: SizedBox(height: 20)), // Add space
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
                          onPressed: () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9CE1CF), 
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
                          ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
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
                  fillColor: Color.fromARGB(255, 52, 81, 82),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Color.fromARGB(255, 52, 81, 82)),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full name is required';
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
                      fillColor: Color.fromARGB(255, 52, 81, 82),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Color.fromARGB(255, 52, 81, 82)),
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
                      suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF9CE1CF)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of birth is required';
                      }
                      return null;
                    },
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
                    fontSize: 12.0, // Smaller font size
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
                fillColor: Color.fromARGB(255, 52, 81, 82),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color.fromARGB(255, 52, 81, 82)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
              dropdownColor: Colors.white, // Set dropdown background color
              hint: Text(
                'Select blood type',
                style: TextStyle(
                  color: Color.fromRGBO(195, 195, 195, 1),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                ),
              ),
              iconEnabledColor: Color(0xFF9CE1CF),
              iconDisabledColor: Colors.grey,
              style: TextStyle(color: Colors.black), // Set dropdown text color to black
              selectedItemBuilder: (BuildContext context) {
                return <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map<Widget>((String value) {
                  return Text(
                    value,
                    style: TextStyle(color: Colors.white), // Set input field text color to white
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
                bloodController.text = newValue!;
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
                    fontSize: 10.0, // Smaller font size
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
                fillColor: Color.fromARGB(255, 52, 81, 82),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color.fromARGB(255, 52, 81, 82)),
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
                    fontSize: 10.0, // Smaller font size
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
                fillColor: Color.fromARGB(255, 52, 81, 82),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color.fromARGB(255, 52, 81, 82)),
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


  void backToLogin(BuildContext context) {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
