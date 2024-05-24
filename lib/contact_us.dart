import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 24, top: 24),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color.fromRGBO(255, 255, 255, 1),
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 38,left: 75),
          child: Text(
          "Contact Us",
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        )
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80,),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child : _buildContact(
                context,
                title: 'GitHub',
                description:
                    'https://github.com/nataliaamah/hawa_v2',
            ),
            ),
            SizedBox(height: 40,),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child : _buildContact(
                context,
                title: 'Instagram',
                description:
                    'https://instagram.com/nataliaamah',
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContact(BuildContext context, {required String title, required String description}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      );
  }
}
