// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/models/video.dart';
import 'package:techtalk/techtalk/services/youtube_service.dart';
import 'package:techtalk/techtalk/widgets/video%20widgets/videoitem_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  final Logger _logger = Logger();
  final YouTubeService _youtubeService = YouTubeService();
  
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchVideos(); // Only fetch videos the first time app is opened
  }

  Future<void> _fetchVideos({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final newVideos = await _youtubeService.fetchVideos();
      
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _videos.addAll(newVideos); // Add new videos to the existing list
          } else {
            _videos = newVideos; // Replace the existing list with the new one
          }
          _isLoading = false;
          _errorMessage = _videos.isEmpty ? 'No videos found' : '';
        });
      }
    } catch (e) {
      _logger.e('Video fetch error', error: e);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load videos. Check your connection.';
        });
        
        _showErrorSnackBar(e);
      }
    }
  }

  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: ${error.toString()}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: () => _fetchVideos(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Theme(
      data: _buildThemeData(),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 57, 57, 57),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Colors.green.shade400,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Tech Talks',
        style: GoogleFonts.protestRevolution(),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _fetchVideos(isRefresh: true),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _videos.isEmpty) {
      return _buildLoadingIndicator();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    return _buildVideoList();
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
            'Loading videos...',
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
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return RefreshIndicator(
      backgroundColor: Colors.green.shade700,
      color: Colors.white,
      onRefresh: () async {
        await _fetchVideos(isRefresh: true); // Trigger refresh
      },
      child: _videos.isEmpty
          ? _buildEmptyStateWidget()
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _videos.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.green.shade800,
                height: 1,
                thickness: 0.5,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: VideoItemWidget(video: _videos[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 100,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No videos available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
