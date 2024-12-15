// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techtalk/techtalk/navigations/bottombar.dart';
import 'package:techtalk/techtalk/screens/signup_or_signin.dart';
import 'package:techtalk/techtalk/screens/splash_screen.dart';

class AuthRoute extends StatefulWidget {
  const AuthRoute({super.key});

  @override
  State<AuthRoute> createState() => _AuthRouteState();
}

class _AuthRouteState extends State<AuthRoute> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Show SplashScreen briefly
    await Future.delayed(const Duration(seconds: 2));

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      // Check if user exists in the database
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        // User is authenticated and exists in the database
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Bottombar()),
          (route) => false,
        );
      } else {
        // User is authenticated but not in the database
        await FirebaseAuth.instance.signOut();
        _navigateToSignupOrSignin();
      }
    } else {
      // User is not authenticated
      _navigateToSignupOrSignin();
    }
  }

  void _navigateToSignupOrSignin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignupOrSignin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
