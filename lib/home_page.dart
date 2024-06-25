import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hawa_v1/login_page.dart';
import 'package:hawa_v1/profile_page.dart';
import 'half_circle_painter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_us.dart';
import 'contact_us.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:logger/logger.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:telephony/telephony.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:hawa_v1/contact_emergency.dart';

class HomePage extends StatefulWidget {
  final String fullName;
  final String userId;
  final bool isAuthenticated;

  HomePage({required this.fullName, required this.userId, this.isAuthenticated = false});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double _glowRadius = 10.0;
  late Timer _timer;
  List<bool> _buttonStates = [false, false, false, false];
  String _emergencyNumber = "";
  final Logger logger = Logger(); // Initialize the logger
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  final Telephony telephony = Telephony.instance;
  bool _emergencyMessageSent = false;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  bool _isAuthenticated = false;
  Completer<void>? _popupCompleter;
  Timer? _debounceTimer;

  static const platform = MethodChannel('com.hawa.application/location');

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.isAuthenticated;
    _startGlowAnimation();
    if (_isAuthenticated) {
      _fetchEmergencyNumber();
    }
    _initializeCamera();
    if (_isAuthenticated) {
      _startShakeDetection(); // Start shake detection only if the user is authenticated
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_isAuthenticated) {
      _gyroscopeSubscription.cancel();
    }
    _cameraController?.dispose();
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

  Future<void> _showLoginRequiredDialog() async {
    _popupCompleter = Completer<void>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feature Locked'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This feature is locked.'),
                Text('Automate this process by logging in.'),
                Text('Please log in or sign up to access it.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage())).then((value) {
                  // Check if the user is authenticated after the login page returns
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    setState(() {
                      _isAuthenticated = true;
                    });
                    _popupCompleter?.complete();
                  }
                });
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (!_popupCompleter!.isCompleted) {
                  _popupCompleter!.complete();
                }
              },
            ),
          ],
        );
      },
    );
    await _popupCompleter!.future;
  }

  Future<bool> _showEnterEmergencyContactDialog() async {
    TextEditingController emergencyContactController = TextEditingController();

    bool? contactEntered = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emergencyContactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter emergency contact number',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Automate this process by logging in.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () {
                if (emergencyContactController.text.isNotEmpty) {
                  setState(() {
                    _emergencyNumber = emergencyContactController.text;
                  });
                  Navigator.of(context).pop(true); // Contact entered
                }
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // Contact not entered
              },
            ),
          ],
        );
      },
    );

    return contactEntered ?? false;
  }

  Future<void> _initiateCall() async {
    if (!_isAuthenticated) {
      bool contactEntered = await _showEnterEmergencyContactDialog();
      if (!contactEntered) {
        return; // User did not enter a contact, do not proceed
      }
    }

    if (_emergencyNumber.isNotEmpty) {
      final Uri url = Uri(scheme: 'tel', path: _emergencyNumber);
      logger.d('Attempting to launch $url');
      var status = await perm.Permission.phone.status;
      if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
        logger.d('Phone permission not granted. Requesting permission.');
        status = await perm.Permission.phone.request();
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

  // Function to initialize the camera
  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _cameraController = CameraController(firstCamera, ResolutionPreset.high);
      _initializeControllerFuture = _cameraController!.initialize();
    } catch (e) {
      logger.e('Error initializing camera: $e');
    }
  }

  // Function to take 5 successive pictures
  Future<void> _takePictures() async {
    if (!_isAuthenticated) {
      bool contactEntered = await _showEnterEmergencyContactDialog();
      if (!contactEntered) {
        return; // User did not enter a contact, do not proceed
      }
    }

    try {
      await _initializeControllerFuture;

      List<String> imageUrls = [];
      for (int i = 0; i < 5; i++) {
        final image = await _cameraController!.takePicture();
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = path.join(directory.path, '${DateTime.now()}_$i.png');
        await image.saveTo(imagePath);
        logger.d('Picture saved to $imagePath');
        final imageUrl = await _uploadImageToCloudStorage(imagePath);
        imageUrls.add(imageUrl);
        logger.d('Image $i uploaded to $imageUrl');
      }

      await _saveEmergencyDataToFirestore(imageUrls, false);
    } catch (e) {
      logger.e('Error taking pictures: $e');
    }
  }

  // Function to upload image to cloud storage
  Future<String> _uploadImageToCloudStorage(String imagePath) async {
    File file = File(imagePath);
    String fileName = path.basename(file.path);
    Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask;
    String returnURL = await storageReference.getDownloadURL();
    return returnURL;
  }

  // Function to save data to Firestore
  Future<void> _saveEmergencyDataToFirestore([List<String> imageUrls = const [], bool isShakeEmergency = false]) async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    await FirebaseFirestore.instance.collection('contact_emergency').add({
      'userId': widget.userId,
      'emergencyNumber': _emergencyNumber,
      'imageUrls': imageUrls,
      'location': GeoPoint(_locationData.latitude!, _locationData.longitude!),
      'timestamp': FieldValue.serverTimestamp(),
      'resolved': false,
      'isShakeEmergency': isShakeEmergency,
    });

    logger.d('Data saved to Firestore successfully.');
  }

  Future<void> _callEmergencyNumber() async {
    final Uri emergencyUri = Uri(scheme: 'tel', path: '999');
    if (await canLaunchUrl(emergencyUri)) {
      await launchUrl(emergencyUri);
    } else {
      logger.e('Could not launch $emergencyUri');
    }
  }

  void _startShakeDetection() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      final double shakeThreshold = 10.0; // Increased value to detect larger shakes
      final int debounceTime = 2000; // 2 seconds debounce time

      if (!_emergencyMessageSent &&
          (event.x.abs() > shakeThreshold ||
              event.y.abs() > shakeThreshold ||
              event.z.abs() > shakeThreshold)) {
        _handleShakeEmergency();
        _emergencyMessageSent = true;

        // Reset the emergency message flag after the debounce time
        _debounceTimer?.cancel();
        _debounceTimer = Timer(Duration(milliseconds: debounceTime), () {
          _emergencyMessageSent = false;
        });
      }
    });
  }

  void _handleShakeEmergency() async {
    if (!_isAuthenticated) {
      await _showLoginRequiredDialog();
      return;
    }

    // Save data to Firestore indicating a shake emergency
    await _saveEmergencyDataToFirestore([], true);
  }

  @override
  Widget build(BuildContext context) {
    String firstName = getFirstName(widget.fullName);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(197, 197, 197, 1),
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
      ),
      drawer: AppDrawer(isAuthenticated: _isAuthenticated, userId: widget.userId),
      body: Builder(
        builder: (context) => Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 250),
              painter: HalfCirclePainter( Color.fromRGBO(2, 1, 34, 1)),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Icon(Icons.menu_rounded, color: Color.fromRGBO(197, 197, 197, 1), size: 40),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId, isAuthenticated: widget.isAuthenticated))).then((value) {
                        setState(() {
                          // This will refresh the state and update the welcome message
                        });
                      });
                    },
                    icon: Icon(Icons.account_circle_rounded, size: 40, color: Color.fromRGBO(197, 197, 197, 1)),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 70), // Adjust the height accordingly
                Center(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 1000),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(248, 51, 60, 0.6),
                          spreadRadius: _glowRadius,
                          blurRadius: _glowRadius,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_isAuthenticated) {
                          await _showLoginRequiredDialog();
                        } else {
                          _handleShakeEmergency();
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'S.O.S',
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.w900,
                                fontSize: 55,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Color.fromRGBO(248, 51, 60, 1),
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
                            color: const Color.fromRGBO(2, 1, 34, 1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (!widget.isAuthenticated)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    SizedBox(height: 40),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        ElevatedButton(
                          onPressed: () => _initiateCall(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, size: 48),
                              SizedBox(height: 4), // Add some space between the icon and the text
                              Text(
                                "Call\nEmergency\nContact",
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[0] ? Color.fromRGBO(197, 197, 197, 1) : Color.fromRGBO(2, 1, 34, 1),
                            foregroundColor: _buttonStates[0] ? Color.fromRGBO(2, 1, 34, 1) : Color.fromRGBO(197, 197, 197, 1),
                            minimumSize: Size(100, 150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Color.fromRGBO(197, 197, 197, 1)),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _takePictures(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 48),
                              SizedBox(height: 4), // Add some space between the icon and the text
                              Text(
                                "Take\nPicture",
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _buttonStates[1] ? Color.fromRGBO(197, 197, 197, 1) : Color.fromRGBO(2, 1, 34, 1),
                            foregroundColor: _buttonStates[1] ? Color.fromRGBO(2, 1, 34, 1) : Color.fromRGBO(197, 197, 197, 1),
                            minimumSize: Size(128, 150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Color.fromRGBO(197, 197, 197, 1)),
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
  final bool isAuthenticated;
  final String userId;

  AppDrawer({required this.isAuthenticated, required this.userId});

  Future<String?> _fetchPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc['phoneNumber'];
    }
    return null;
  }

  Future<String?> _fetchFullName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['fullName'];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 45, 45, 45),
      child: ListView(
        children: <Widget>[
          SizedBox(height: 30),
          ListTile(
            contentPadding: EdgeInsets.only(left: 230),
            leading: Icon(Icons.close_rounded, size: 30, color: Color.fromRGBO(255, 255, 255, 1)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 100),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('Emergency Alerts', style: TextStyle(fontSize: 20, color: Color.fromRGBO(248, 51, 60, 1), fontWeight: FontWeight.w800)),
            onTap: () {
              if (isAuthenticated) {
                _fetchPhoneNumber().then((phoneNumber) {
                  if (phoneNumber != null) {
                    _fetchFullName(userId).then((fullName) {
                      if (fullName != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactEmergencyPage(
                              phoneNumber: phoneNumber,
                              fullName: fullName,
                              userId: userId,
                              isAuthenticated: isAuthenticated,
                            ),
                          ),
                        ).then((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage(isAuthenticated: isAuthenticated, fullName: fullName, userId: userId)),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Full name not found'),
                          ),
                        );
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone number not found'),
                      ),
                    );
                  }
                });
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Feature Locked'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('This feature is locked.'),
                            Text('Please log in or sign up to access it.'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Login'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage())).then((value) {
                              // Check if the user is authenticated after the login page returns
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context).pop(); // Close the dialog
                              }
                            });
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('About Us', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
          ),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.only(left: 50),
            title: Text('Contact Us', style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactUsPage()));
            },
          ),
          SizedBox(height: 250),
          ListTile(
            leading: Icon(Icons.logout_rounded, size: 25, color: Color.fromRGBO(255, 255, 255, 1)),
            contentPadding: EdgeInsets.only(left: 50),
            title: Text(
              isAuthenticated ? 'Logout' : 'Login/Sign Up',
              style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 255, 255, 1)),
            ),
            onTap: () {
              if (isAuthenticated) {
                // Sign out the user
                FirebaseAuth.instance.signOut().then((_) {
                  // Navigate to HomePage with limited functionalities
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(isAuthenticated: false, fullName: 'Guest', userId: '')),
                    (route) => false, // Remove all previous routes
                  );
                });
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              }
            },
          ),
        ],
      ),
    );
  }
}
