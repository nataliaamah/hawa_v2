import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

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

  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
  }

  int _calculateAge(String dateOfBirth) {
    if (dateOfBirth.isEmpty) {
      return -1; // Invalid age
    }
    final dob = DateFormat('dd/MM/yyyy').parse(dateOfBirth);
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? data = emergencyData.data() as Map<String, dynamic>?;
    final String userId = data?['userId'] ?? ''; // Ensure userId field exists
    final GeoPoint location = data?['location'] ?? GeoPoint(0, 0);
    final List<String> imageUrls = List<String>.from(data?['imageUrls'] ?? []);
    final double latitude = location.latitude;
    final double longitude = location.longitude;
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
      body: userId.isEmpty
          ? Center(child: Text('Invalid User ID', style: TextStyle(color: Colors.white)))
          : FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserDetails(userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final userDetails = snapshot.data!;
                final String senderName = userDetails['fullName'] ?? '-';
                final String age = userDetails['dateOfBirth'] != null
                    ? _calculateAge(userDetails['dateOfBirth']).toString()
                    : '-';
                final String bloodType = userDetails['bloodType'] ?? '-';
                final String phoneNumber = userDetails['phoneNumber'] ?? '-';
                final String medication = userDetails['medication'] ?? '-';
                final String allergies = userDetails['allergies'] ?? '-';

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
                          Center(
                            child: Text(
                              'A large shake has been detected from $senderName. They may be in danger.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
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
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserInfoRow('Full Name', senderName),
                              _buildUserInfoRow('Age', age),
                              _buildUserInfoRow('Phone Number', phoneNumber),
                              _buildUserInfoRow('Blood Type', bloodType),
                              _buildUserInfoRow('Medication', medication),
                              _buildUserInfoRow('Allergies', allergies),
                            ],
                          ),
                        ),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image.network(imageUrls[index]),
                                    ),
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

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGalleryPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  ImageGalleryPage({required this.imageUrls, required this.initialIndex});

  Future<void> _saveImageToDevice(String imageUrl, BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission not granted')),
        );
        return;
      }
    }

    try {
      var response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image')),
        );
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
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
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () => _saveImageToDevice(imageUrls[initialIndex], context),
          child: Icon(Icons.download),
        ),
      ),
    );
  }
}
