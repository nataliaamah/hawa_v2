import 'dart:async';
import 'dart:io';
import 'dart:math';
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
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hawa_v1/contact_emergency_view.dart' as contactView;
import 'appdrawer.dart';

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
  bool _isSnapping = false;
  int _snappedPictures = 0;
  int maxPictures = 5;
  String? _currentEmergencyId;
  DateTime? _lastAlertTime;
  bool _canSendAlert = true;
  bool _isProcessingAlert = false;
  bool _sosPressed = false;
  bool _alertSent = false;
  int _countdown = 10;
  bool _retracted = false;
  StreamSubscription<DocumentSnapshot>? _retractedSubscription;

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
      _retractedSubscription?.cancel();
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
        if (contactNumber != null && contactNumber is String && (contactNumber.isNotEmpty)) {
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

  // Function to take multiple pictures
  Future<void> _takePictures() async {
    if (!_isAuthenticated) {
      bool contactEntered = await _showEnterEmergencyContactDialog();
      if (!contactEntered) {
        return; // User did not enter a contact, do not proceed
      }
    }

    try {
      await _initializeControllerFuture;

      // Initialize the emergency alert entry in Firestore
      _currentEmergencyId = await _initializeEmergencyAlert();

      _isSnapping = true;
      _snappedPictures = 0;
      setState(() {});

      for (int i = 0; i < maxPictures && _isSnapping; i++) {
        final image = await _cameraController!.takePicture();
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = path.join(directory.path, '${DateTime.now()}_$i.png');
        await image.saveTo(imagePath);
        logger.d('Picture saved to $imagePath');
        final imageUrl = await _uploadImageToCloudStorage(imagePath);
        await _updateEmergencyAlert(imageUrl);
        logger.d('Image $i uploaded to $imageUrl');

        // Increase haptic feedback intensity
        Vibrate.feedback(FeedbackType.success);
        _snappedPictures++;
        setState(() {});

        await Future.delayed(Duration(milliseconds: 1000)); // Shorter interval between snaps
      }

      _isSnapping = false;
      setState(() {});
    } catch (e) {
      logger.e('Error taking pictures: $e');
    }
  }

  // Function to initialize the emergency alert in Firestore
  Future<String> _initializeEmergencyAlert() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception('Location service not enabled');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }

    _locationData = await location.getLocation();

    DocumentReference docRef = await FirebaseFirestore.instance.collection('contact_emergency').add({
      'userId': widget.userId,
      'emergencyNumber': _emergencyNumber,
      'imageUrls': [],
      'location': GeoPoint(_locationData.latitude!, _locationData.longitude!),
      'timestamp': FieldValue.serverTimestamp(),
      'resolved': false,
    });

    logger.d('Emergency alert initialized with ID: ${docRef.id}');
    return docRef.id;
  }

  // Function to update the emergency alert with new image URL
  Future<void> _updateEmergencyAlert(String imageUrl) async {
    if (_currentEmergencyId != null) {
      await FirebaseFirestore.instance.collection('contact_emergency').doc(_currentEmergencyId).update({
        'imageUrls': FieldValue.arrayUnion([imageUrl]),
      });

      logger.d('Emergency alert updated with new image URL: $imageUrl');
    } else {
      logger.e('No current emergency ID found to update');
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

  // Function to initialize the SOS emergency alert in Firestore
  Future<String> _initializeSosEmergencyAlert() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception('Location service not enabled');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }

    _locationData = await location.getLocation();

    DocumentReference docRef = await FirebaseFirestore.instance.collection('staff_emergency').add({
      'userId': widget.userId,
      'location': GeoPoint(_locationData.latitude!, _locationData.longitude!),
      'timestamp': FieldValue.serverTimestamp(),
      'resolved': false,
      'retracted': false,
    });

    logger.d('SOS emergency alert initialized with ID: ${docRef.id}');
    return docRef.id;
  }

  void _startShakeDetection() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      final double shakeThreshold = 13.0; // Increased value to detect larger shakes
      final angularVelocity = sqrt(event.x * event.x + event.y * event.y + event.z * event.z); // Calculate the angular velocity magnitude

      if (!_isProcessingAlert && !_isSnapping && angularVelocity > shakeThreshold) {
        _isProcessingAlert = true;
        _handleShakeEmergency();

        Vibrate.feedback(FeedbackType.warning); // Haptic feedback on shake detection
        _showShakeDetectionAlert(); // Show alert popup

        _disableGyroscopeFor10Seconds(); // Disable gyroscope for 10 seconds after detecting shake
      }
    });
  }

  void _showShakeDetectionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Shake Detected'),
          content: Text('Unusual movement detected. Emergency alert sent to contact.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel Alert'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAlert();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _disableGyroscopeFor10Seconds() {
    // Stop listening to the gyroscope events
    _gyroscopeSubscription.cancel();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 10), () {
      _isProcessingAlert = false;
      _startShakeDetection();
    });
  }

  void _cancelAlert() {
    _isProcessingAlert = false;
    _startShakeDetection();
  }

  void _handleShakeEmergency() {
    print('Shake emergency detected and alert sent.');
  }

  void _showSnappingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Snapping pictures... $_snappedPictures/$maxPictures',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSnapping = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Stop Snapping'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleSosPress() {
    setState(() {
      _sosPressed = true;
      _countdown = 10;
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _alertSent = true;
        });
        // Send SOS alert
        _sendSosAlert();
      }
    });
  }

  void _sendSosAlert() async {
    try {
      _currentEmergencyId = await _initializeSosEmergencyAlert();
      _retractedSubscription = FirebaseFirestore.instance
          .collection('staff_emergency')
          .doc(_currentEmergencyId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _retracted = snapshot.data()?['retracted'] ?? false;
            if (_retracted) {
              _sosPressed = false;
              _alertSent = false;
            }
          });
        }
      });
      logger.d('SOS alert sent.');
    } catch (e) {
      logger.e('Error sending SOS alert: $e');
    }
  }

  void _cancelSosAlert() async {
    if (_currentEmergencyId != null) {
      await FirebaseFirestore.instance.collection('staff_emergency').doc(_currentEmergencyId).update({
        'retracted': true,
      });
      setState(() {
        _sosPressed = false;
        _alertSent = false;
        _countdown = 10;
      });
      logger.d('SOS alert retracted.');
    }
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
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: Color.fromRGBO(197, 197, 197, 1), size: 40),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_rounded, size: 40, color: Color.fromRGBO(197, 197, 197, 1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId, isAuthenticated: widget.isAuthenticated)),
              ).then((value) {
                setState(() {
                  // This will refresh the state and update the welcome message
                });
              });
            },
          ),
        ],
      ),
      drawer: AppDrawer(isAuthenticated: _isAuthenticated, userId: widget.userId),
      body: Builder(
        builder: (context) => Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 250),
              painter: HalfCirclePainter(Color.fromRGBO(2, 1, 34, 1)),
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
                      onPressed: _sosPressed
                          ? null
                          : () {
                              _handleSosPress();
                            },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _sosPressed
                              ? Text(
                                  _alertSent ? "Hold tight." : 'Sending alert in $_countdown',
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontWeight: FontWeight.w900,
                                      fontSize: _alertSent ? 25 : 25,
                                    ),
                                  ),
                                )
                              : Text(
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
                if (_sosPressed)
                  TextButton(
                    onPressed: () {
                      _cancelSosAlert();
                    },
                    child: Text(
                      _alertSent ? 'Retract Alert' : 'Cancel Alert',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
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
                          onPressed: () {
                            _showSnappingIndicator();
                            _takePictures();
                          },
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
