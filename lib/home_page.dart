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
  List<bool> _buttonStates = [false, false, false, false];

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
                        color: Color.fromARGB(255, 80, 190, 179).withOpacity(0.6),
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
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      ElevatedButton.icon(
                    onPressed: () => _toggleButtonState(0),
                    icon: Icon(Icons.phone, size: 24),
                    label: Text("Call"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonStates[0] ? Color.fromRGBO(253, 231, 76, 1) : Colors.transparent,
                      foregroundColor: _buttonStates[0] ? Color.fromARGB(255, 45, 45, 45) : Color.fromRGBO(253, 231, 76, 1),
                      minimumSize: Size(152.5, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color.fromRGBO(253, 231, 76, 1)),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _toggleButtonState(1),
                    icon: Icon(Icons.camera_alt, size: 24),
                    label: Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonStates[1] ? Color.fromRGBO(247, 86, 124, 1) : Colors.transparent,
                      foregroundColor: _buttonStates[1] ? Color.fromARGB(255, 45, 45, 45) : Color.fromRGBO(247, 86, 124, 1),
                      minimumSize: Size(152.5, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color.fromRGBO(247, 86, 124, 1)),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _toggleButtonState(2),
                    icon: Icon(Icons.vibration, size: 24),
                    label: Text("Detect Shake"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonStates[2] ? Color.fromRGBO(128, 206, 215, 1) : Colors.transparent,
                      foregroundColor: _buttonStates[2] ? Color.fromARGB(255, 45, 45, 45) : Color.fromRGBO(128, 206, 215, 1),
                      minimumSize: Size(320, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color.fromRGBO(128, 206, 215, 1)),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _toggleButtonState(3),
                    icon: Icon(Icons.location_on, size: 24),
                    label: Text("Share Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonStates[3] ? Color.fromRGBO(196, 174, 247, 1) : Colors.transparent,
                      foregroundColor: _buttonStates[3] ? Color.fromARGB(255, 45, 45, 45) : Color.fromRGBO(196, 174, 247, 1),
                      minimumSize: Size(320, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color.fromRGBO(196, 174, 247, 1)),
                      ),
                    )
                  )
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
