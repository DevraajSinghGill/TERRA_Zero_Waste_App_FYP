import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../constants/chat_stream.dart';
import '../../../../models/group_model.dart';
import '../../../../models/user_model.dart';
import '../../../../services/chat_services.dart';
import '../../../../services/group_chat_services.dart';

class PostSendingPortion extends StatefulWidget {
  final String postId;
  const PostSendingPortion({super.key, required this.postId});

  @override
  State<PostSendingPortion> createState() => _PostSendingPortionState();
}

class _PostSendingPortionState extends State<PostSendingPortion> {
  Map<String, bool> isLoadingMap = {};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    child: Column(
                      children: [
                        Text("Send Post", style: AppTextStyles.nunitoBold),
                        SizedBox(height: 10.h),
                        StreamBuilder(
                          stream: ChatStream().combineChatStreamForPost(),
                          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            var chats = snapshot.data;
                            return ListView.builder(
                                itemCount: chats!.length,
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  var chat = chats[index];

                                  String specificIdForLoading;
                                  if (chat.reference.path.contains('chats')) {
                                    specificIdForLoading = chat['chatId'];
                                  } else if (chat.reference.path.contains('groupChats')) {
                                    specificIdForLoading = chat['groupId'];
                                  } else {
                                    return SizedBox();
                                  }

                                  bool isLoading = isLoadingMap[specificIdForLoading] ?? false;

                                  if (chat.reference.path.contains('chats')) {
                                    String otherUserId =
                                        chat['uids'].firstWhere((id) => id != FirebaseAuth.instance.currentUser!.uid);

                                    return StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection('users').doc(otherUserId).snapshots(),
                                      builder: (context, snap) {
                                        if (!snap.hasData) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        UserModel userModel = UserModel.fromMap(snap.data!);

                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: userModel.image == ""
                                                  ? CircleAvatar(
                                                      radius: 25,
                                                      child: Icon(Icons.person),
                                                    )
                                                  : CircleAvatar(
                                                      radius: 25,
                                                      backgroundImage: NetworkImage(userModel.image),
                                                    ),
                                              title: Text(userModel.username),
                                              subtitle: Text(DateFormat('dd-MM-yyyy').format(userModel.memberSince)),
                                              trailing: isLoading
                                                  ? CircularProgressIndicator()
                                                  : TextButton(
                                                      onPressed: () async {
                                                        setState(() {
                                                          isLoadingMap[specificIdForLoading] = true;
                                                        });
                                                        await ChatServices().sendMsg(
                                                          context: context,
                                                          msg: "Post",
                                                          docId: chat['chatId'],
                                                          userId: otherUserId,
                                                          image: null,
                                                          postId: widget.postId,
                                                        );
                                                        setState(() {
                                                          isLoadingMap[specificIdForLoading] = false;
                                                        });
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text(
                                                        "Send Post",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors.primaryBlack,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        backgroundColor: Colors.grey,
                                                      ),
                                                    ),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      },
                                    );
                                  } else if (chat.reference.path.contains('groupChats')) {
                                    GroupModel group = GroupModel.fromMap(chat);

                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: group.groupImage == ""
                                              ? CircleAvatar(
                                                  radius: 25,
                                                  child: Icon(Icons.group),
                                                )
                                              : CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage: NetworkImage(group.groupImage),
                                                ),
                                          title: Text(group.groupName),
                                          subtitle: Text(DateFormat('dd-MM-yyyy').format(group.createdAt)),
                                          trailing: isLoading
                                              ? CircularProgressIndicator()
                                              : TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoadingMap[specificIdForLoading] = true;
                                                    });
                                                    await GroupChatServices().sendMsgInGroup(
                                                      context: context,
                                                      msg: "Post",
                                                      groupId: group.groupId,
                                                      image: null,
                                                      postId: widget.postId,
                                                    );
                                                    setState(() {
                                                      isLoadingMap[specificIdForLoading] = false;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "Send Post",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.primaryBlack,
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    backgroundColor: Colors.grey,
                                                  ),
                                                ),
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                });
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.share));
  }
}
