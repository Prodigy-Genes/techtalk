// user_model.dart
class UserModel {
  final String userId;
  final String email;
  final String pictureUrl;
  final String username;

  UserModel({
    required this.userId,
    required this.email,
    required this.pictureUrl,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'pictureUrl': pictureUrl,
      'username': username,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'],
      email: map['email'],
      pictureUrl: map['pictureUrl'],
      username: map['username'],
    );
  }
}
