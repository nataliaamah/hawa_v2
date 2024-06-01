import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_painter.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicationController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactNumberController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with empty text first
    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _bloodTypeController = TextEditingController();
    _allergiesController = TextEditingController();
    _medicationController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactNumberController = TextEditingController();
    fetchUserData();
  }

  void fetchUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    setState(() {
      _fullNameController.text = doc['fullName'];
      _dateOfBirthController.text = doc['dateOfBirth'];
      _bloodTypeController.text = doc['bloodType'];
      _allergiesController.text = doc['allergies'];
      _medicationController.text = doc['medication'];
      _contactNameController.text = doc['contactName'];
      _contactNumberController.text = doc['contactNumber'];
    });
  }

  void saveUserData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'fullName': _fullNameController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'bloodType': _bloodTypeController.text,
        'allergies': _allergiesController.text,
        'medication': _medicationController.text,
        'contactName': _contactNameController.text,
        'contactNumber': _contactNumberController.text,
      });

      Navigator.pop(context); // Go back to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 10, 38, 39),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: _fullNameController.text.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 70),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CustomPaint(
                          size: Size(double.infinity, MediaQuery.of(context).size.height - 20),
                          painter: PersonalInfoPainter(),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: _fullNameController,
                                    decoration: InputDecoration(labelText: 'Full Name'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _dateOfBirthController,
                                    decoration: InputDecoration(labelText: 'Date of Birth'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your date of birth';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _bloodTypeController,
                                    decoration: InputDecoration(labelText: 'Blood Type'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your blood type';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _allergiesController,
                                    decoration: InputDecoration(labelText: 'Allergies'),
                                  ),
                                  TextFormField(
                                    controller: _medicationController,
                                    decoration: InputDecoration(labelText: 'Current Medication'),
                                  ),
                                  TextFormField(
                                    controller: _contactNameController,
                                    decoration: InputDecoration(labelText: 'Emergency Contact Name'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an emergency contact name';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _contactNumberController,
                                    decoration: InputDecoration(labelText: 'Emergency Contact Number'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an emergency contact number';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Cancel'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                              foregroundColor: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: ElevatedButton(
                                            onPressed: saveUserData,
                                            child: Text('Save'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black87,
                                              backgroundColor: Colors.teal[700],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
