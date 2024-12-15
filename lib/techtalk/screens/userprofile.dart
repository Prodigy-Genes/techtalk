import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtalk/techtalk/models/user.dart';
import 'package:techtalk/techtalk/widgets/signout_widgets/signout_button.dart';
import 'package:techtalk/techtalk/widgets/user%20details/profile_picture_widget.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.green.shade400,
          ),
        ),
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green.shade700,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 41, 41, 41),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              'User Profile', 
              style: GoogleFonts.protestRevolution(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              
            ),
            actions: const [SignOutButton()],
          ),
          body: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error fetching data',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        color: Colors.green.shade400,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'User not found',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final userModel = UserModel.fromMap(userData);

              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade900.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.shade700,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ProfilePictureWidget(
                                pictureUrl: userModel.pictureUrl,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                userModel.username,
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userModel.email,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.green.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}