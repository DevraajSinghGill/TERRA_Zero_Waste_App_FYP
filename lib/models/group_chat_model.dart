import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatModel {
  final String userId;
  final String username;
  final String userImage;
  final String msg;
  final String image;
  final String postId;
  final DateTime sendingTime;

  const GroupChatModel({
    required this.userId,
    required this.username,
    required this.userImage,
    required this.postId,
    required this.msg,
    required this.image,
    required this.sendingTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'postId': postId,
      'userImage': userImage,
      'msg': msg,
      'image': image,
      'sendingTime': sendingTime,
    };
  }

  factory GroupChatModel.fromDoc(DocumentSnapshot snap) {
    return GroupChatModel(
      userId: snap['userId'] as String,
      username: snap['username'] as String,
      postId: snap['postId'] as String,
      userImage: snap['userImage'] as String,
      image: snap['image'] as String,
      msg: snap['msg'] as String,
      sendingTime: (snap['sendingTime'].toDate()),
    );
  }
}
