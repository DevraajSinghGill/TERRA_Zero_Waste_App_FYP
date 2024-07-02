import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String postId;
  final String userId;
  final String username;
  final String userImage;
  final String comment;
  final DateTime commentTime;

  const CommentModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userImage,
    required this.comment,
    required this.commentTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': this.postId,
      'userId': this.userId,
      'username': this.username,
      'userImage': this.userImage,
      'comment': this.comment,
      'commentTime': this.commentTime,
    };
  }

  factory CommentModel.fromMap(DocumentSnapshot map) {
    return CommentModel(
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      username: map['username'] as String,
      userImage: map['userImage'] as String,
      comment: map['comment'] as String,
      commentTime: (map['commentTime'].toDate()),
    );
  }
}
