import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:hawa_v1/contact_emergency.dart';

class ContactEmergencyViewPage extends StatelessWidget {
  final DocumentSnapshot emergencyData;

  ContactEmergencyViewPage({required this.emergencyData});

  void _openInGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _markAsResolved(BuildContext context) async {
    await FirebaseFirestore.instance.collection('contact_emergency').doc(emergencyData.id).update({
      'resolved': true,
    });
    Navigator.pop(context);
  }

  Future<String?> _fetchUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc['fullName'] : 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final String userId = emergencyData['userId'];
    final GeoPoint location = emergencyData['location'];
    final List<String> imageUrls = List<String>.from(emergencyData['imageUrls']);
    final double latitude = location.latitude;
    final double longitude = location.longitude;
    final Map<String, dynamic>? data = emergencyData.data() as Map<String, dynamic>?;
    final bool isShakeEmergency = data != null && data.containsKey('isShakeEmergency')
        ? data['isShakeEmergency']
        : false;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(2, 1, 34, 1),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image.asset(
          'assets/images/hawa_name.png',
          height: 200,
          width: 200,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () => _markAsResolved(context),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _fetchUserName(userId),
        builder: (context, snapshot) {
          String senderName = snapshot.data ?? 'Unknown User';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                  child: Text(
                    '$senderName\'s Emergency',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ),
                  if (isShakeEmergency) ...[
                    SizedBox(height: 20),
                    Text(
                      'A large shake has been detected from $senderName',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (imageUrls.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                      '$senderName shared pictures of their surroundings and their location. They may be in danger.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ),
                  ],
                  SizedBox(height: 20),
                  Text(
                    'Shared Location',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(226, 192, 68, 1),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 14.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('emergencyLocation'),
                            position: LatLng(latitude, longitude),
                          ),
                        },
                        onTap: (_) => _openInGoogleMaps(latitude, longitude),
                      ),
                    ),
                  ),
                  if (imageUrls.isNotEmpty) ...[
                    SizedBox(height: 20),
                    Text(
                      'Shared Pictures',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(226, 192, 68, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageGalleryPage(imageUrls: imageUrls, initialIndex: index),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image.network(imageUrls[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageGalleryPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  ImageGalleryPage({required this.imageUrls, required this.initialIndex});

  Future<void> _saveImageToDevice(String imageUrl) async {
    // Add your implementation to save the image to the device
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveImageToDevice(imageUrls[initialIndex]),
        child: Icon(Icons.download),
      ),
    );
  }
}
