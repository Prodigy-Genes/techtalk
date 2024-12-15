// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:techtalk/techtalk/models/video.dart';

class LikedVideosWidget extends StatefulWidget {
  final Function(VideoModel)? onVideoTap;

  const LikedVideosWidget({super.key, this.onVideoTap});

  @override
  _LikedVideosWidgetState createState() => _LikedVideosWidgetState();
}

class _LikedVideosWidgetState extends State<LikedVideosWidget> {
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

  List<VideoModel> _likedVideos = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, YoutubePlayerController> _videoControllers = {};
  final Map<String, bool> _isVideoInitialized = {};

  @override
  void initState() {
    super.initState();
    _fetchLikedVideos();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _videoControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _fetchLikedVideos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please log in to view liked videos';
          _isLoading = false;
        });
        return;
      }

      _logger.d('Fetching liked videos for user: ${user.uid}');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('likedVideos')
          .get();

      // Detailed debugging
      for (var doc in querySnapshot.docs) {
        _logger.d('Document ID: ${doc.id}');
        _logger.d('Raw Document Data: ${doc.data()}');

        // Print out all keys in the document
        doc.data().keys.forEach((key) {
          _logger.d('Key: $key, Value: ${doc.data()[key]}');
        });
      }

      setState(() {
        _likedVideos = querySnapshot.docs.map((doc) {
          final data = doc.data();
          _logger.d('Attempting to parse video: $data');
          return VideoModel.fromFirestore(data);
        }).toList();
        _isLoading = false;
        _logger.d('Fetched ${_likedVideos.length} liked videos');

        for (var video in _likedVideos) {
          _logger.d('Parsed Video - Title: ${video.title}, '
              'Channel: ${video.channelTitle}, '
              'Description: ${video.description}');
        }
      });
    } catch (e) {
      _logger.e('Error fetching liked videos', error: e);
      setState(() {
        _errorMessage = 'Failed to load liked videos';
        _isLoading = false;
      });
    }
  }

  void _removeVideoFromLiked(VideoModel video) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('likedVideos')
          .doc(video.id)
          .delete();

      // Dispose of the controller if it exists
      _videoControllers[video.id]?.dispose();
      _videoControllers.remove(video.id);

      setState(() {
        _likedVideos.removeWhere((v) => v.id == video.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${video.title}" from liked videos'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _logger.e('Error removing liked video', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeVideoController(VideoModel video) {
    if (_isVideoInitialized[video.id] ?? false) return;

    try {
      String? videoId = YoutubePlayer.convertUrlToId(video.videoUrl);
      if (videoId == null) {
        _logger.e('Invalid YouTube URL for video: ${video.title}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid video URL')),
        );
        return;
      }

      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );

      setState(() {
        _videoControllers[video.id] = controller;
        _isVideoInitialized[video.id] = true;
      });
    } catch (e) {
      _logger.e('Error initializing video controller', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchLikedVideos,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_likedVideos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No liked videos yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _likedVideos.length,
      itemBuilder: (context, index) {
        return _buildLikedVideoCard(_likedVideos[index]);
      },
      separatorBuilder: (context, index) {
        return const Divider(color: Colors.grey); 
      },
    );
  }

  Widget _buildLikedVideoCard(VideoModel video) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVideoPlayer(video),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoHeader(video),
                const SizedBox(height: 8),
                _buildVideoDetails(video),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(VideoModel video) {
    // If controller is not initialized, show thumbnail
    if (!(_isVideoInitialized[video.id] ?? false)) {
      return GestureDetector(
        onTap: () => _initializeVideoController(video),
        child: Stack(
          alignment: Alignment.center,
          children: [
            video.thumbnailUrl == null
                ? const CircularProgressIndicator() // Show loader if no thumbnail
                : Image.network(
                    video.thumbnailUrl ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 64,
              ),
            ),
          ],
        ),
      );
    }

    // If controller is initialized, show YouTube player
    return YoutubePlayer(
      controller: _videoControllers[video.id]!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      bottomActions: const [
        CurrentPosition(),
        ProgressBar(isExpanded: true),
        RemainingDuration(),
      ],
    );
  }

  Widget _buildVideoHeader(VideoModel video) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: video.channelProfileUrl != null
                    ? NetworkImage(video.channelProfileUrl!)
                    : null,
                child: video.channelProfileUrl == null
                    ? Icon(Icons.person, color: Colors.grey.shade400)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  video.channelTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed to white for dark theme
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _removeVideoFromLiked(video),
          tooltip: 'Remove from Liked Videos',
        ),
      ],
    );
  }

  Widget _buildVideoDetails(VideoModel video) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          video.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          video.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
