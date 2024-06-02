import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hawa_v1/login_page.dart';
import 'package:hawa_v1/profile_page.dart';
import 'half_circle_painter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_us.dart';
import 'contact_us.dart';
import 'profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:telephony/telephony.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class HomePage extends StatefulWidget {
  final String fullName;
  final String userId;

  HomePage({required this.fullName, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double _glowRadius = 10.0;
  late Timer _timer;
  List<bool> _buttonStates = [false, false, false, false];
  String _emergencyNumber = "";
  final Logger logger = Logger(); // Initialize the logger
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final Telephony telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _startGlowAnimation();
    _fetchEmergencyNumber();
    _initializeCamera();
  }

  @override
  void dispose() {
    _timer.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  void _toggleButtonState(int index) {
    setState(() {
      _buttonStates[index] = !_buttonStates[index];
    });
  }

  void _startGlowAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        _glowRadius = _glowRadius == 10.0 ? 15.0 : 10.0;
      });
    });
  }

  String getFirstName(String fullName) {
    return fullName.split(' ')[0];
  }

  void _fetchEmergencyNumber() async {
    logger.d('Fetching emergency contact number for user ID: ${widget.userId}');
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (documentSnapshot.exists) {
        logger.d('Document exists for user ID: ${widget.userId}');
        var contactNumber = documentSnapshot['contactNumber'];
        if (contactNumber != null && contactNumber is String && contactNumber.isNotEmpty) {
          setState(() {
            _emergencyNumber = contactNumber.startsWith('+') ? contactNumber : '+$contactNumber';
          });
          logger.d('Fetched emergency number: $_emergencyNumber');
        } else {
          logger.w('Contact number is null or empty');
        }
      } else {
        logger.w('Document does not exist for user ID: ${widget.userId}');
      }
    } catch (e) {
      logger.e('Error fetching emergency contact: $e');
    }
  }

  Future<void> _initiateCall() async {
    if (_emergencyNumber.isNotEmpty) {
      final Uri url = Uri(scheme: 'tel', path: _emergencyNumber);
      logger.d('Attempting to launch $url');
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        logger.d('Phone permission not granted. Requesting permission.');
        status = await Permission.phone.request();
      }
      if (status.isGranted) {
        logger.d('Phone permission granted.');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
          logger.d('Launched $url successfully.');
        } else {
          logger.e('Could not launch $url');
        }
      } else {
        logger.w('Phone call permission not granted.');
      }
    } else {
      logger.w('Emergency number is empty.');
    }
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, '${DateTime.now()}.png');
      await image.saveTo(imagePath);
      logger.d('Picture saved to $imagePath');
      final imageUrl = await _uploadImageToCloudStorage(imagePath);
      logger.d('Image uploaded to $imageUrl');
      await _sendSMSWithPicture(imageUrl);
    } catch (e) {
      logger.e('Error taking picture: $e');
    }
  }

  Future<String> _uploadImageToCloudStorage(String imagePath) async {
    File file = File(imagePath);
    String fileName = path.basename(file.path);
    Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask;
    String returnURL = await storageReference.getDownloadURL();
    return returnURL;
  }

  Future<void> _sendSMSWithPicture(String imageUrl) async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.sendSms(
        to: _emergencyNumber,
        message: 'Emergency! Here is the picture: $imageUrl',
      ).then((_) {
        logger.d('SMS sent successfully with image URL: $imageUrl');
      }).catchError((error) {
        logger.e('Failed to send SMS: $error');
      });
    } else {
      logger.w('SMS permission not granted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstName = getFirstName(widget.fullName);

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
      ),
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) => Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 200),
              painter: HalfCirclePainter(Colors.teal[700]!),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Icon(Icons.menu_rounded, color: Color.fromARGB(255, 10, 38, 39), size: 40),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8, left: 260),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)));
                    },
                    icon: Icon(Icons.account_circle_rounded, size: 40, color: Color.fromARGB(255, 10, 38, 39)),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 35), // Adjust the height accordingly
                Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 1000),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 80, 190, 179).withOpacity(0.6),
                          spreadRadius: _glowRadius,
                          blurRadius: _glowRadius,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (){},
                      child: Text(
                        'S.O.S',
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                            color: Colors.teal[900], // Darker teal color for better contrast
                            fontWeight: FontWeight.w900,
                            fontSize: 60, // Adjust font size for better readability
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.teal[200],
                        padding: EdgeInsets.all(83),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Welcome, $firstName",
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                            fontSize: 30,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _initiateCall(),
                          icon: Icon(Icons.phone, size: 24),
                          label: Text("Call", style: TextStyle(fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[0] ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 10, 38, 39),
                            foregroundColor: _buttonStates[0] ? Color.fromARGB(255, 10, 38, 39) : Color.fromARGB(255, 255, 255, 255),
                            minimumSize: Size(152.5, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _takePicture(),
                          icon: Icon(Icons.camera_alt, size: 24),
                          label: Text("Camera", style: TextStyle(fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[1] ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 10, 38, 39),
                            foregroundColor: _buttonStates[1] ? Color.fromARGB(255, 10, 38, 39) : Color.fromARGB(255, 255, 255, 255),
                            minimumSize: Size(152.5, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _toggleButtonState(2),
                          icon: Icon(Icons.vibration, size: 24),
                          label: Text("Detect Shake", style: TextStyle(fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[2] ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 10, 38, 39),
                            foregroundColor: _buttonStates[2] ? Color.fromARGB(255, 10, 38, 39) : Color.fromARGB(255, 255, 255, 255),
                            minimumSize: Size(320, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _toggleButtonState(3),
                          icon: Icon(Icons.location_on, size: 24),
                          label: Text("Share Location", style: TextStyle(fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[3] ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 10, 38, 39),
                            foregroundColor: _buttonStates[3] ? Color.fromARGB(255, 10, 38, 39) : Color.fromARGB(255, 255, 255, 255),
                            minimumSize: Size(320, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 45, 45, 45),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 30,),
          ListTile(
            contentPadding: EdgeInsets.only(left: 230),
            leading: Icon(Icons.close_rounded, size: 30, color: Color.fromRGBO(255, 255, 255, 1),),
            onTap: () {
              Navigator.pop(context);  
            },
          ),
          SizedBox(height: 100,),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('About Us', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.w500),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
          ),
          SizedBox(height: 20,),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('Contact Us', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.w500),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsPage()));
            },
          ),
          SizedBox(height: 350,),
          ListTile(
            leading: Icon(Icons.logout_rounded, size: 25, color: Color.fromRGBO(255, 255, 255, 1),),
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('Logout', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1),),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
