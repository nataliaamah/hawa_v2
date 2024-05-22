import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<void> signUpWithEmail(String email, String password, Map<String, dynamic> userData) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      // Check if user is not null
      if (user != null) {
        // Store additional user data in Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);
      }
    } catch (e) {
      print("Error: $e");
      throw e; // Re-throw the error to handle it in the calling function
    }
  }
}
