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
  @override
  void initState() {
    super.initState();
    if (!widget.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAuthenticationPopup());
    }
  }

  Future<DocumentSnapshot> fetchUserData() async {
    return await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
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
      backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 1, 34, 1),
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
          : FutureBuilder<DocumentSnapshot>(
              future: fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No data found'));
                }

                var userDocument = snapshot.data!.data() as Map<String, dynamic>;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Center(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromRGBO(226, 192, 68, 1),
                              child: Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              userDocument['fullName'] ?? 'none',
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
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(userId: widget.userId),
                                ),
                              );
                              setState(() {}); // Trigger a rebuild to refresh the data
                            },
                            child: Center(
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(226, 192, 68, 1),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color.fromRGBO(226, 192, 68, 1),
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
                                    _buildInfoRow('Full Name', userDocument['fullName']),
                                    _buildInfoRow('Date of Birth', userDocument['dateOfBirth']),
                                    _buildInfoRow('Phone Number', userDocument['phoneNumber']),
                                    _buildInfoRow('Blood Type', userDocument['bloodType']),
                                    _buildInfoRow('Allergies', userDocument['allergies']),
                                    _buildInfoRow('Current Medication', userDocument['currentMedication']),
                                    _buildInfoRow('Emergency Contact Name', userDocument['contactName']),
                                    _buildInfoRow('Emergency Contact Number', userDocument['contactNumber']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
