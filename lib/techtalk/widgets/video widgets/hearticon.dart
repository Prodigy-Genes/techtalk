// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/models/likedvideos.dart';
import 'package:techtalk/techtalk/models/video.dart';

class LikeVideoButton extends StatefulWidget {
  final VideoModel video;
  final bool isLiked;

  const LikeVideoButton({
    super.key,
    required this.video,
    this.isLiked = false,
  });

  @override
  _LikeVideoButtonState createState() => _LikeVideoButtonState();
}

class _LikeVideoButtonState extends State<LikeVideoButton> {
  // Initialize logger
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
  }

  Future<void> _toggleLikeVideo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar('Please log in to like videos');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final likedVideosRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('likedVideos');

      if (!_isLiked) {
        // Create a LikedVideo instance
        final likedVideo = LikedVideo(
          id: widget.video.id,
          title: widget.video.title,
          description: widget.video.description,
          videoUrl: widget.video.videoUrl,
          channelTitle: widget.video.channelTitle,
          channelId: widget.video.channelId,
          publishedAt: widget.video.publishedAt,
          channelProfileUrl: widget.video.channelProfileUrl,
          thumbnailUrl: widget.video.thumbnailUrl,
          userId: user.uid,
        );

        // Add the video to the likedVideos collection
        await likedVideosRef.doc(widget.video.id).set(likedVideo.toMap());

        _logger.i('Video liked: ${widget.video.title}');
        _showSnackBar('Video liked!');
      } else {
        // Remove the video from the likedVideos collection
        await likedVideosRef.doc(widget.video.id).delete();

        _logger.i('Video unliked: ${widget.video.title}');
        _showSnackBar('Video unliked');
      }

      setState(() {
        _isLiked = !_isLiked;
      });
    } on FirebaseException catch (e) {
      _logger.e('Firestore Error: ${e.code}', error: e);
      _showSnackBar('Failed to ${_isLiked ? 'unlike' : 'like'} video. Please try again.');
    } catch (e) {
      _logger.e('Unexpected error in like/unlike', error: e);
      _showSnackBar('An unexpected error occurred');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_border,
        color: _isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleLikeVideo,
    );
  }
}
