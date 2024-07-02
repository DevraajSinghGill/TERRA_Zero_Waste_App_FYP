import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final List postImages;
  final String caption;

  final String userId;
  final String userImage;
  final String username;
  final DateTime createdAt;

  final List likedBy;

  const PostModel({
    required this.postId,
    required this.postImages,
    required this.caption,
    required this.userId,
    required this.userImage,
    required this.username,
    required this.createdAt,
    required this.likedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': this.postId,
      'postImage': this.postImages,
      'caption': this.caption,
      'userId': this.userId,
      'userImage': this.userImage,
      'username': this.username,
      'createdAt': this.createdAt,
      'likedBy': this.likedBy,
    };
  }

  factory PostModel.fromMap(DocumentSnapshot map) {
    return PostModel(
      postId: map['postId'] as String,
      postImages: map['postImage'] as List,
      caption: map['caption'] as String,
      userId: map['userId'] as String,
      userImage: map['userImage'] as String,
      username: map['username'] as String,
      createdAt: (map['createdAt'].toDate()),
      likedBy: map['likedBy'] as List,
    );
  }
}
