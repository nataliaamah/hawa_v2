import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 150, bottom: 20),
              title: Text(
                "Contact Us",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
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
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child : Text("Feel free to contact us to ask questions about our app!", style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),),
                      ),
                      SizedBox(height: 50,),
                      Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: _buildContact(
                          context,
                          title: 'GitHub',
                          description: 'https://github.com/nataliaamah/hawa_v2',
                          link: true,
                        ),
                      ),
                      SizedBox(height: 30,),
                      Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: _buildContact(
                          context,
                          title: 'Email',
                          description: 'ameranataliamah@gmail.com\nillailanadiah@gmail.com\nafiqahrahim@gmail.com\taliahanisah@gmail.com',
                          link: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContact(BuildContext context, {required String title, required String description, bool link = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color.fromRGBO(255, 255, 255, 1)),
          ),
          SizedBox(height: 10,),
          GestureDetector(
            onTap: link
                ? () async {
                    if (await canLaunch(description)) {
                      await launch(description);
                    } else {
                      throw 'Could not launch $description';
                    }
                  }
                : null,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: link ? Colors.blue : const Color.fromARGB(255, 255, 255, 255),
                decoration: link ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
