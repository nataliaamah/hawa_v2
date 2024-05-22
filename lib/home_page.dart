import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'half_circle_painter.dart'; 
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final String title;
  final String fullName;

  HomePage({required this.title, required this.fullName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double _glowRadius = 10.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startGlowAnimation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    String firstName = getFirstName(widget.fullName);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 45, 45),
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
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 200),
            painter: HalfCirclePainter(Colors.teal[700]!),
          ),
          Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 20),
              child : IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hamburger menu clicked")));
                },
                icon : Icon(Icons.menu_rounded, color: Color.fromARGB(255, 45, 45, 45), size: 40,),
              )
              ),
              Padding(padding: EdgeInsets.only(right: 10, left: 240),
              child : IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile clicked")));
                },
                icon : Icon(Icons.account_circle_rounded, size: 40, color: Color.fromARGB(255, 45, 45, 45)),
              )
              )
            ]
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30), 
              Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 7, 170, 154).withOpacity(0.6),
                        spreadRadius: _glowRadius,
                        blurRadius: _glowRadius,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'S.O.S',
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                          color: Colors.teal[900], // Darker teal color for better contrast
                          fontWeight: FontWeight.w900,
                          fontSize: 50, // Adjust font size for better readability
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Colors.teal[200], // Light teal color
                      padding: EdgeInsets.all(90), // Adjust padding to fit better
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children : [ 
                  Center(
                    child: Text( "Welcome, " + firstName,
                    style: GoogleFonts.quicksand(textStyle: TextStyle(fontSize: 30, color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.w500)),
                    )
                  ),
                  SizedBox(height: 60),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {

                        },
                        icon: Icon(Icons.phone, size: 24),
                        label: Text("Call"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(155, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {

                        },
                        icon: Icon(Icons.camera_alt, size: 24),
                        label: Text("Camera"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(155, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {

                        },
                        icon: Icon(Icons.vibration, size: 24),
                        label: Text("Detect Shake"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(320, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {

                        },
                        icon: Icon(Icons.location_on, size: 24),
                        label: Text("Share Location"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: Size(320, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ]
            ),
            ],
          ),
        ],
      ),
    );
  }
}
