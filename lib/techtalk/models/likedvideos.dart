import 'package:cloud_firestore/cloud_firestore.dart';

class LikedVideo {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String channelTitle;
  final String channelId;
  final String publishedAt;
  final String? channelProfileUrl;
  final String? thumbnailUrl;
  final String userId;

  LikedVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    this.channelProfileUrl,
    this.thumbnailUrl,
    required this.userId,
  });

  // Convert a LikedVideo instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'channelTitle': channelTitle,
      'channelId': channelId,
      'publishedAt': publishedAt,
      'channelProfileUrl': channelProfileUrl,
      'thumbnailUrl': thumbnailUrl,
      'userId': userId,
    };
  }

  // Create a LikedVideo instance from a Firestore document snapshot
  factory LikedVideo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikedVideo(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      videoUrl: data['videoUrl'],
      channelTitle: data['channelTitle'],
      channelId: data['channelId'],
      publishedAt: data['publishedAt'],
      channelProfileUrl: data['channelProfileUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      userId: data['userId'],
    );
  }
}
