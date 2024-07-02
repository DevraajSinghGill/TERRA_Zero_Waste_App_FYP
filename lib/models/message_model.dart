import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String msg;
  final String image;
  final String senderId;
  final String username;
  final String userImage;
  final String postId;
  final DateTime sendingTime;

  const MessageModel({
    required this.msg,
    required this.image,
    required this.senderId,
    required this.username,
    required this.userImage,
    required this.postId,
    required this.sendingTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'msg': this.msg,
      'image': this.image,
      'senderId': this.senderId,
      'username': this.username,
      'userImage': this.userImage,
      'postId': this.postId,
      'sendingTime': this.sendingTime,
    };
  }

  factory MessageModel.fromMap(DocumentSnapshot map) {
    return MessageModel(
      msg: map['msg'] as String,
      image: map['image'] as String,
      senderId: map['senderId'] as String,
      username: map['username'] as String,
      userImage: map['userImage'] as String,
      postId: map['postId'] as String,
      sendingTime: (map['sendingTime'].toDate()),
    );
  }
}
