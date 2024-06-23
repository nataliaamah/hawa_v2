import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_painter.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final bool isAuthenticated;

  ProfilePage({required this.userId, this.isAuthenticated = false});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DocumentSnapshot? userDocument;

  @override
  void initState() {
    super.initState();
    if (!widget.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAuthenticationPopup());
    } else {
      fetchUserData();
    }
  }

  void fetchUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    setState(() {
      userDocument = doc;
    });
  }

  void _showAuthenticationPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Authentication Required"),
          content: Text("Please log in to access this page."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 38, 39),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 10, 38, 39),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image.asset(
          'assets/images/hawa_name.png',
          height: 200,
          width: 200,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !widget.isAuthenticated
          ? Center(child: Text(''))
          : userDocument == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Center(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.teal[700],
                              child: Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              (userDocument!.data() as Map<String, dynamic>)['fullName'] ?? 'none',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              // Navigate to EditProfilePage and wait for the result
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(userId: widget.userId),
                                ),
                              );
                              // Reload the user data after returning from EditProfilePage
                              fetchUserData();
                            },
                            child: Center(
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.teal[200],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.teal[200],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: CustomPaint(
                              size: Size(double.infinity, MediaQuery.of(context).size.height - 20),
                              painter: PersonalInfoPainter(),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                                    _buildInfoRow('Full Name', (userDocument!.data() as Map<String, dynamic>)['fullName']),
                                    _buildInfoRow('Date of Birth', (userDocument!.data() as Map<String, dynamic>)['dateOfBirth']),
                                    _buildInfoRow('Phone Number', (userDocument!.data() as Map<String, dynamic>)['phoneNumber']),
                                    _buildInfoRow('Blood Type', (userDocument!.data() as Map<String, dynamic>)['bloodType']),
                                    _buildInfoRow('Allergies', (userDocument!.data() as Map<String, dynamic>)['allergies']),
                                    _buildInfoRow('Current Medication', (userDocument!.data() as Map<String, dynamic>)['currentMedication']),
                                    _buildInfoRow('Emergency Contact Name', (userDocument!.data() as Map<String, dynamic>)['contactName']),
                                    _buildInfoRow('Emergency Contact Number', (userDocument!.data() as Map<String, dynamic>)['contactNumber']),
                                  ],
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

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
          ),
          Text(
            value != null && value.toString().isNotEmpty ? value.toString() : 'none',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
