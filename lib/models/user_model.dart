import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String username;
  final String about;
  final String email;
  final String image;
  final List followers;
  final List following;
  final List savePosts;
  final DateTime memberSince;
  final String role;
  final int combinedPoints; // Add this field

  const UserModel({
    required this.userId,
    required this.username,
    required this.about,
    required this.email,
    required this.image,
    required this.followers,
    required this.following,
    required this.savePosts,
    required this.memberSince,
    required this.role,
    this.combinedPoints = 300, // Default to 300 points
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': this.userId,
      'username': this.username,
      'email': this.email,
      'about': this.about,
      'image': this.image,
      'followers': this.followers,
      'following': this.following,
      'savePosts': this.savePosts,
      'memberSince': this.memberSince,
      'role': this.role,
      'combinedPoints': this.combinedPoints, // Include in the map
    };
  }

  factory UserModel.fromMap(DocumentSnapshot map) {
    return UserModel(
      userId: map['userId'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      about: map['about'] as String,
      image: map['image'] as String,
      followers: map['followers'] as List,
      following: map['following'] as List,
      savePosts: map['savePosts'] as List,
      memberSince: (map['memberSince'].toDate()),
      role: map['role'] as String,
      combinedPoints: map['combinedPoints'] ?? 300, // Default to 300 if not present
    );
  }
}
