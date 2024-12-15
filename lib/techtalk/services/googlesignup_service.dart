// google_signup_service.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/models/user.dart';
import 'package:techtalk/techtalk/navigations/bottombar.dart';

class GoogleSignupService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();

  Future<void> signUpWithGoogle(BuildContext context) async {
  try {
    // Initiate Google Sign-In
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      _logger.w('Google sign-in canceled by user');
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // Check if the user already exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // If user exists, instruct them to log in instead
        _logger.i('User already exists in Firestore: ${user.email}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account already exists. Please log in instead.'),
          ),
        );
        return;
      }

      // Add user details to Firestore
      final userModel = UserModel(
        userId: user.uid,
        email: user.email ?? '',
        pictureUrl: user.photoURL ?? '',
        username: user.displayName ?? 'Unnamed User',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      _logger.i('User signed up and added to Firestore: ${userModel.email}');

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up successful!')),
      );

      // Navigate to the BottomBar screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Bottombar()),
        (route) => false,
      );
    }
  } on FirebaseAuthException catch (e) {
    _logger.e('FirebaseAuthException during Google sign-up, $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-up failed: ${e.message}')),
    );
  } catch (e) {
    _logger.e('Unexpected error during Google sign-up, $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An unexpected error occurred.')),
    );
  }
}

}
