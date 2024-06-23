import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hawa_v1/contact_emergency_view.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ContactEmergencyPage extends StatefulWidget {
  final String phoneNumber;
  final String fullName;
  final String userId;
  final bool isAuthenticated;

  ContactEmergencyPage({
    required this.phoneNumber,
    required this.fullName,
    required this.userId,
    required this.isAuthenticated,
  });

  @override
  _ContactEmergencyPageState createState() => _ContactEmergencyPageState();
}

class _ContactEmergencyPageState extends State<ContactEmergencyPage> {
  bool _isVibrating = false;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseFirestore.instance
        .collection('contact_emergency')
        .where('emergencyNumber', isEqualTo: _formatPhoneNumber(widget.phoneNumber))
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.any((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return data != null && data['resolved'] == false;
      })) {
        if (!_isVibrating) {
          _startVibrating();
        }
      } else {
        _stopVibrating();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      return '+$phoneNumber';
    }
    return phoneNumber;
  }

  Future<String?> _fetchUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc['fullName'] : 'Unknown User';
  }

  void _startVibrating() {
    _isVibrating = true;
    _vibrate();
  }

  void _vibrate() async {
    if (_isVibrating && await Vibrate.canVibrate) {
      Vibrate.vibrateWithPauses([Duration(milliseconds: 500), Duration(milliseconds: 500)]);
    }
  }

  void _stopVibrating() {
    _isVibrating = false;
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')} | ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 38, 39),
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image.asset(
          'assets/images/hawa_name.png',
          height: 200,
          width: 200,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  fullName: widget.fullName,
                  userId: widget.userId,
                  isAuthenticated: widget.isAuthenticated,
                ),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              'Emergency Alerts',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  fontSize: 27,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(
              "Emergencies from people who set you as emergency contact will show here",
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  fontSize: 15,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.w400,
                ),
              ),
              textAlign: TextAlign.center,
              ),
              ),
            ),
          SizedBox(height: 30,),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('contact_emergency')
                  .where('emergencyNumber', isEqualTo: _formatPhoneNumber(widget.phoneNumber))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> emergencyDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>?;
                  return data != null;
                }).toList();

                if (emergencyDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'There are no emergencies.',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: emergencyDocs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot emergencyData = emergencyDocs[index];
                    final data = emergencyData.data() as Map<String, dynamic>?;
                    if (data == null) {
                      return SizedBox.shrink(); // Handle null data case
                    }

                    bool isResolved = data['resolved'] ?? true;
                    bool isNew = !isResolved && _isVibrating;

                    return FutureBuilder<String?>(
                      future: _fetchUserName(data['userId']),
                      builder: (context, snapshot) {
                        String userName = snapshot.data ?? 'Unknown User';
                        return GestureDetector(
                          onTap: () {
                            if (isNew) {
                              _stopVibrating();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactEmergencyViewPage(emergencyData: emergencyData),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: isResolved ? Colors.transparent : Colors.yellow.withOpacity(0.6),
                                  spreadRadius: 10,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                '$userName Needs Help!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Emergency at ${_formatTimestamp(data['timestamp'])}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              trailing: Icon(
                                isResolved ? Icons.check_circle : Icons.warning,
                                color: isResolved ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
