import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
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
                "About Us",
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfile(
                        context,
                        image: 'assets/images/natalia.png',
                        name: 'Amera Natalia Mah',
                        role: 'Back-end Developer',
                      ),
                      _buildProfile(
                        context,
                        image: 'assets/images/illaila.png',
                        name: 'Nur Illaila Nadiah',
                        role: 'Front-end Developer',
                      ),
                      _buildProfile(
                        context,
                        image: 'assets/images/afiqah.png',
                        name: 'Nur Afiqah',
                        role: 'Quality Assurance',
                      ),
                      _buildProfile(
                        context,
                        image: 'assets/images/aliah.png',
                        name: 'Aliah Anisah',
                        role: 'Project Manager',
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

  Widget _buildProfile(BuildContext context, {required String image, required String name, required String role}) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            image,
            width: 300,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 5),
        Text(
          name,
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
          role,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        SizedBox(height: 50),
      ],
    );
  }
}
