class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String channelTitle;
  final String channelId;
  final String publishedAt;
  final String? channelProfileUrl;
  final String? thumbnailUrl; // Added thumbnailUrl field
  final String userId; // Added userId field

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    this.channelProfileUrl,
    this.thumbnailUrl, // Added thumbnailUrl to the constructor
    required this.userId, // Added userId to the constructor
  });

  // Factory constructor to create a VideoModel from JSON
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: _parseId(json),
      title: _parseString(json, ['snippet', 'title']),
      description: _parseString(json, ['snippet', 'description']),
      videoUrl: _constructVideoUrl(json),
      channelTitle: _parseString(json, ['snippet', 'channelTitle']),
      channelId: _parseString(json, ['snippet', 'channelId']),
      publishedAt: _parseString(json, ['snippet', 'publishedAt']),
      channelProfileUrl: _constructChannelProfileUrl(json),
      thumbnailUrl: _parseString(json, ['snippet', 'thumbnails', 'high', 'url']), // Parsing thumbnailUrl
      userId: _parseString(json, ['userId']), // Added userId parsing
    );
  }

  // Add this factory constructor to your VideoModel class
factory VideoModel.fromFirestore(Map<String, dynamic> data) {
  return VideoModel(
    id: data['id'] ?? '',
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    videoUrl: data['videoUrl'] ?? '',
    channelTitle: data['channelTitle'] ?? '',
    channelId: data['channelId'] ?? '',
    publishedAt: data['publishedAt'] ?? '',
    channelProfileUrl: data['channelProfileUrl'],
    thumbnailUrl: data['thumbnailUrl'],
    userId: data['userId'] ?? '',
  );
}

  // Helper method to safely parse nested JSON
  static String _parseString(Map<String, dynamic> json, List<String> keys, {String defaultValue = ''}) {
    dynamic value = json;
    for (var key in keys) {
      if (value is Map && value.containsKey(key)) {
        value = value[key];
      } else {
        return defaultValue;
      }
    }
    return value?.toString() ?? defaultValue;
  }

  // Helper method to parse video ID
  static String _parseId(Map<String, dynamic> json) {
    if (json['id'] is String) {
      return json['id'];
    } else if (json['id'] is Map && json['id']['videoId'] != null) {
      return json['id']['videoId'];
    }
    return '';
  }

  // Construct video URL with fallback
  static String _constructVideoUrl(Map<String, dynamic> json) {
    final videoId = _parseId(json);
    return videoId.isNotEmpty
        ? 'https://www.youtube.com/watch?v=$videoId'
        : '';
  }

  // Construct channel profile URL with better fallback handling
  static String? _constructChannelProfileUrl(Map<String, dynamic> json) {
    final channelId = _parseString(json, ['snippet', 'channelId']);
    return channelId.isNotEmpty
        ? 'https://yt3.googleusercontent.com/ytc/AIdFrame/$channelId=s88-c-k-c0x00ffffff-no-rj'
        : null;
  }

  // Convert VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'channelTitle': channelTitle,
      'channelId': channelId,
      'publishedAt': publishedAt,
      'channelProfileUrl': channelProfileUrl,
      'thumbnailUrl': thumbnailUrl, // Added thumbnailUrl to toJson
      'userId': userId, // Added userId to toJson
    };
  }

  // Equality and hashCode for proper comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Create a copyWith method for easy modification
  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? channelTitle,
    String? channelId,
    String? publishedAt,
    String? channelProfileUrl,
    String? thumbnailUrl, // Added thumbnailUrl to copyWith
    String? userId, // Added userId to copyWith
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      channelTitle: channelTitle ?? this.channelTitle,
      channelId: channelId ?? this.channelId,
      publishedAt: publishedAt ?? this.publishedAt,
      channelProfileUrl: channelProfileUrl ?? this.channelProfileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl, // Added thumbnailUrl to copyWith
      userId: userId ?? this.userId, // Added userId to copyWith
    );
  }

  // Add a method to get a formatted published date
  String getFormattedDate() {
    final dateTime = DateTime.tryParse(publishedAt);
    return dateTime != null
        ? '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'
        : 'Unknown Date';
  }
}
