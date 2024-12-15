// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:techtalk/techtalk/widgets/video%20widgets/hearticon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:logger/logger.dart';
import 'package:techtalk/techtalk/models/video.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoItemWidget extends StatefulWidget {
  final VideoModel video;

  const VideoItemWidget({
    super.key,
    required this.video,
  });

  @override
  State<VideoItemWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> {
  late YoutubePlayerController _controller;
  final Logger _logger = Logger();

  bool _hasVideoLoadError = false;
  String _errorMessage = '';
  bool _isInFocus = false;

  @override
  void initState() {
    super.initState();
    _logger.d('Initializing VideoItemWidget for video: ${widget.video.title}');
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  void _initializeVideoPlayer() {
    if (_isValidVideoUrl(widget.video.videoUrl)) {
      try {
        _logger
            .d('Initializing video player for URL: ${widget.video.videoUrl}');
        String? videoId = YoutubePlayer.convertUrlToId(widget.video.videoUrl);
        if (videoId != null) {
          _controller.load(videoId);
        } else {
          _handleVideoInitializationError('Invalid YouTube URL');
        }
      } catch (e) {
        _handleVideoInitializationError(e);
      }
    } else {
      _handleVideoInitializationError('Invalid video URL');
    }
  }

  bool _isValidVideoUrl(String url) {
    bool isValid = url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
    _logger.d('Checking video URL: $url - Valid: $isValid');
    return isValid;
  }

  void _handleVideoInitializationError(dynamic error) {
    _logger.e('Video initialization error', error: error);
    setState(() {
      _hasVideoLoadError = true;
      _errorMessage = error.toString();
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.8 && !_isInFocus) {
      setState(() {
        _isInFocus = true;
        _initializeVideoPlayer();
      });
    } else if (info.visibleFraction <= 0.8 && _isInFocus) {
      setState(() {
        _isInFocus = false;
        _controller.pause();
        _logger.d('Video paused as it went out of focus');
      });
    }
  }

  @override
  void dispose() {
    _logger.d('Disposing video player controller');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('Building VideoItemWidget');
    return VisibilityDetector(
      key: Key('video-${widget.video.videoUrl}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVideoPlayerOrError(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChannelInfo(),
                  const SizedBox(height: 8),
                  _buildVideoDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerOrError() {
    if (_hasVideoLoadError) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
        color: Colors.red[100],
        child: Center(
          child: Text(
            'Failed to load video: $_errorMessage',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
      ),
    );
  }

  Widget _buildChannelInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                // Extract channel URL from the video URL
                if (_isValidVideoUrl(widget.video.videoUrl)) {
                  try {
                    // Extract channel identifier from YouTube URL
                    Uri videoUri = Uri.parse(widget.video.videoUrl);

                    // Check if pathSegments contains enough parts (at least 2 segments)
                    if (videoUri.pathSegments.length > 1) {
                      // Construct a YouTube channel URL
                      String channelUrl =
                          'https://www.youtube.com/channel/${videoUri.pathSegments[1]}';

                      final Uri channelUri = Uri.parse(channelUrl);
                      if (await canLaunchUrl(channelUri)) {
                        await launchUrl(channelUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        // Fallback if launching fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not open YouTube channel')),
                        );
                      }
                    } else {
                      // If the URL doesn't contain a valid channel path
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invalid YouTube video URL')),
                      );
                    }
                  } catch (e) {
                    // Log any errors
                    _logger.e('Error launching channel URL', error: e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error opening YouTube channel')),
                    );
                  }
                } else {
                  // Show a message if no video URL is available
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video URL not available')),
                  );
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: widget.video.channelProfileUrl != null
                    ? NetworkImage(widget.video.channelProfileUrl!)
                    : null,
                child: widget.video.channelProfileUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.video.channelTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        LikeVideoButton(video: widget.video),
      ],
    );
  }

  Widget _buildVideoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.video.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.video.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
