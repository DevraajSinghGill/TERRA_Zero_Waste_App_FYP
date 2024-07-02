import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String groupImage;
  final String groupName;
  final String lastMsg;
  final DateTime createdAt;
  final List userIds;
  final List adminIds;
  final String groupCreatorId;
  final String groupCreatorName;
  final DateTime lastMsgTime;

  const GroupModel({
    required this.groupId,
    required this.groupImage,
    required this.groupName,
    required this.lastMsg,
    required this.createdAt,
    required this.userIds,
    required this.adminIds,
    required this.groupCreatorId,
    required this.groupCreatorName,
    required this.lastMsgTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': this.groupId,
      'groupImage': this.groupImage,
      'groupName': this.groupName,
      'lastMsg': this.lastMsg,
      'createdAt': this.createdAt,
      'userIds': this.userIds,
      'adminIds': this.adminIds,
      'groupCreatorId': this.groupCreatorId,
      'groupCreatorName': this.groupCreatorName,
      'lastMsgTime': this.lastMsgTime,
    };
  }

  factory GroupModel.fromMap(DocumentSnapshot map) {
    return GroupModel(
        groupId: map['groupId'] as String,
        groupImage: map['groupImage'] as String,
        groupName: map['groupName'] as String,
        lastMsg: map['lastMsg'] as String,
        createdAt: (map['createdAt'].toDate()),
        userIds: map['userIds'] as List,
        adminIds: map['adminIds'] as List,
        groupCreatorId: map['groupCreatorId'] as String,
        groupCreatorName: map['groupCreatorName'] as String,
        lastMsgTime: (map['lastMsgTime'].toDate()));
  }
}
