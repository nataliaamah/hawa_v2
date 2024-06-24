import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hawa_v1/contact_emergency_view.dart';
import 'package:hawa_v1/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter_vibrate/flutter_vibrate.dart';

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
  Timer? _vibrationTimer;
  List<DocumentSnapshot> emergencyDocs = [];

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseFirestore.instance
        .collection('contact_emergency')
        .where('emergencyNumber', isEqualTo: _formatPhoneNumber(widget.phoneNumber))
        .snapshots()
        .listen((snapshot) {
      emergencyDocs = snapshot.docs;
      emergencyDocs.sort((a, b) {
        Timestamp aTimestamp = a['timestamp'];
        Timestamp bTimestamp = b['timestamp'];
        return bTimestamp.compareTo(aTimestamp);
      });
      if (emergencyDocs.any((doc) {
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
    _vibrationTimer?.cancel();
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
    if (_isVibrating) {
      try {
        if (await Vibrate.canVibrate) {
          _vibrationTimer = Timer.periodic(Duration(seconds: 2), (_) {
            Vibrate.vibrateWithPauses([
              Duration(milliseconds: 1500),
              Duration(milliseconds: 500)
            ]);
          });
        }
      } catch (e) {
        print('Error while vibrating: $e');
      }
    }
  }

  void _stopVibrating() {
    _isVibrating = false;
    _vibrationTimer?.cancel();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown Time';
    }
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.year != now.year) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return '${date.day}/${date.month}';
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown Time';
    }
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmergencyList(List<DocumentSnapshot> docs, bool isResolvedList) {
    final filteredDocs = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data != null && data['resolved'] == isResolvedList;
    }).toList();

    if (filteredDocs.isEmpty && !isResolvedList) {
      return Center(
        child: Text(
          'No new emergencies',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        DocumentSnapshot emergencyData = filteredDocs[index];
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
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),  // Increased the top margin
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: isResolved ? Colors.transparent : Color.fromRGBO(248, 51, 60, 0.6),
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
                        'Emergency at ${_formatTime(data['timestamp'])}',
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
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        _formatTimestamp(data['timestamp']),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                'Emergency Alerts',
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold),
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
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'New Emergencies',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10,),
            emergencyDocs.isEmpty
                ? Center(
                    child: Text(
                      'No new emergencies',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : _buildEmergencyList(emergencyDocs, false),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'History',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildEmergencyList(emergencyDocs, true),
          ],
        ),
      ),
    );
  }
}
