import 'dart:async';
import 'package:flutter/material.dart';
import 'half_circle_painter.dart'; 
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({required this.title});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                icon : Icon(Icons.account_circle_outlined, size: 40, color: Color.fromARGB(255, 45, 45, 45)),
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
            ],
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 45, 45, 45), // Set a light background color
    );
  }
}
