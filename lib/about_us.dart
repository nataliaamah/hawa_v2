import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: EdgeInsets.only(left: 24, top: 24),
          child :
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color.fromRGBO(255, 255, 255, 1), size: 25,),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 40),
          child : Text('About Us', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Image.asset(
                "assets/images/natalia.png",
                width: 400, // Adjust the width and height as needed
                height: 300,
                fit: BoxFit.cover, // Ensures the image fits within the specified dimensions
              ),
            SizedBox(height: 10), // Add some spacing between the image and text
            Text(
              'Amera Natalia Mah',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Back-End Developer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            Image.asset(
                "assets/images/natalia.png",
                width: 400, // Adjust the width and height as needed
                height: 300,
                fit: BoxFit.cover, // Ensures the image fits within the specified dimensions
              ),
            SizedBox(height: 10), // Add some spacing between the image and text
            Text(
              'Amera Natalia Mah',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Back-End Developer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ],
        ),
      )

      ),
    );
  }
}
