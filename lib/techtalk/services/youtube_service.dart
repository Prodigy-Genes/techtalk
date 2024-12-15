// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:techtalk/techtalk/models/video.dart';
import 'dart:convert';

class YouTubeService {
  static final String _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _techQueries = [
    'flutter development',
    'react js tutorial',
    'python tutorial',
    'cybersecurity tutorial',
    'machine learning python',
    'software programming tutorials',
    'programming memes',
    'programming hacks',
    'binance crypto updates',
    'crypto trading tips',
    'blockchain technology',
    'web development tutorials',
    'android development',
    'iOS development tutorials',
    'devops best practices',
    'tech industry news',
    'tech conferences',
  ];

  Future<List<VideoModel>> fetchVideos({int limit = 50}) async {
  try {
    final allVideos = <VideoModel>{};

    for (String query in _techQueries) {
      // First, try to fetch videos from Firestore
      final cachedVideos = await _fetchVideosFromFirestore(query, limit: 5);

      if (cachedVideos.isNotEmpty) {
        // If cached videos exist, add them to the set
        allVideos.addAll(cachedVideos);
      } else {
        // If no cached videos, fetch from the YouTube API
        final fetchedVideos = await _fetchVideosForQuery(query);

        // If fetched videos are not empty, store them in Firestore and add to the set
        if (fetchedVideos.isNotEmpty) {
          await _storeVideosInFirestore(query, fetchedVideos);
          allVideos.addAll(fetchedVideos);
        } else {
          print("No videos found for query: $query");
        }
      }
    }

    // Shuffle and limit the results
    final shuffledVideos = allVideos.toList()..shuffle();
    return shuffledVideos.take(limit).toList();
  } catch (e) {
    print("Error in fetchVideos: $e");
    return [];
  }
}


  Future<List<VideoModel>> _fetchVideosForQuery(String query) async {
    final url = Uri.parse(
        'https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=$query&type=video&key=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videosJson = data['items'] ?? [];

        // Ensure that the response is properly mapped to VideoModel objects
        final videos = await Future.wait(videosJson
            .where((video) => video['id']['kind'] == 'youtube#video')
            .map<Future<VideoModel>>((video) async {
          final videoId = video['id']['videoId'];
          final videoDetails = await _fetchVideoDetails(videoId);
          if (videoDetails != null && videoDetails['duration'] != null) {
            final duration = _parseDuration(videoDetails['duration']);
            if (duration <= 31) {
              return VideoModel.fromJson(video); // Return the video if it's less than 31 mins
            }
          }
          throw Exception('Video skipped');
        }));

        // Filter out any null values (videos that were skipped)
        return videos.whereType<VideoModel>().toList();
      } else {
        print('Failed to fetch videos: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching videos for query "$query": $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchVideoDetails(String videoId) async {
    final url = Uri.parse(
        'https://youtube.googleapis.com/youtube/v3/videos?part=contentDetails&id=$videoId&key=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] ?? [];
        if (items.isNotEmpty) {
          return items[0]['contentDetails'];
        }
      } else {
        print('Failed to fetch video details for $videoId: ${response.body}');
      }
    } catch (e) {
      print('Error fetching video details for $videoId: $e');
    }
    return null;
  }

  int _parseDuration(String duration) {
    // Parse ISO 8601 duration format (e.g., "PT30M15S") to minutes
    final regex = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
      return minutes + (seconds >= 30 ? 1 : 0); // Round up if 30 seconds or more
    }
    return 0;
  }

  Future<void> _storeVideosInFirestore(
      String query, List<VideoModel> videos) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is logged in");
      return;
    }
    try {
      final collectionRef = _firestore.collection('videos');
      for (var video in videos) {
        await collectionRef.doc(video.id).set({
          'query': query,
          'snippet': {
            'title': video.title,
            'description': video.description,
            'channelTitle': video.channelTitle,
            'channelId': video.channelId,
            'channelProfileUrl':
                video.channelProfileUrl, // Save channelProfileUrl
          },
          'publishedAt': video.publishedAt,
          'videoUrl': video.videoUrl,
          'userId': user.uid,
          'thumbnailUrl': video.thumbnailUrl, // Added thumbnailUrl if available
        });
      }
    } catch (e) {
      print("Error storing videos in Firestore: $e");
    }
  }

  Future<List<VideoModel>> _fetchVideosFromFirestore(String query,
      {int limit = 10}) async {
    try {
      final collectionRef = _firestore.collection('videos');
      final snapshot = await collectionRef
          .where('query', isEqualTo: query)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final videoData = doc.data();
        return VideoModel(
          id: doc.id,
          title: videoData['snippet']['title'] ?? '',
          description: videoData['snippet']['description'] ?? '',
          videoUrl: videoData['videoUrl'] ?? '',
          channelTitle: videoData['snippet']['channelTitle'] ?? '',
          channelId: videoData['snippet']['channelId'] ?? '',
          publishedAt: videoData['publishedAt'] ?? '',
          userId: videoData['userId'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error fetching videos from Firestore: $e");
      return [];
    }
  }
}
