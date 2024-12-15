// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/navigations/bottombar.dart';

class GooglesigninService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        _showSnackbar(context, 'Sign-in canceled by user');
        return;
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if the user is in Firestore
      final user = userCredential.user;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();

      if (!userDoc.exists) {
        // If the user doesn't exist in Firestore, show a message
        _showSnackbar(context, 'User not found in Firestore, please register');
      } else {
        // If the user is found, navigate to the BottomBar screen
        _showSnackbar(context, 'Welcome ${user?.displayName}');
        // Navigate to the BottomBar screen using pushReplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Bottombar()), // Navigate to BottomBar
        );
      }
    } catch (e) {
      // Log the exception and show a snackbar for the user
      _logger.e('Google sign-in error: $e');
      _showSnackbar(context, 'An error occurred during sign-in. Please try again.');
    }
  }

  // Helper method to show a Snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
