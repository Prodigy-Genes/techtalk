import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtalk/techtalk/utilities/helpers.dart';
import 'package:techtalk/techtalk/widgets/video%20widgets/likedvideo_widget.dart';

class LikedVideosScreen extends StatelessWidget {
  const LikedVideosScreen({super.key});

  Future<String?> _getUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc.id;
        }
      }
    } catch (e) {
      debugPrint('Error fetching userId: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildAppTheme(),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Liked Videos',
        style: GoogleFonts.protestRevolution(),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return FutureBuilder<String?>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildErrorWidget();
        } else {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: LikedVideosWidget(),
          );
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading liked videos...',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading liked videos.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
