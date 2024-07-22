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
          isScrollControlled: true,
          builder: (_) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return FractionallySizedBox(
                  heightFactor: 0.75,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    color: Colors.white, // Set background color to white
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network('https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/message_icon.gif?alt=media&token=b823a499-4255-46f1-b5de-b72e11368d63', width: 50.w, height: 50.h),
                            SizedBox(width: 16),
                            Text(
                              "Send Post",
                              style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp, color: Colors.green),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: StreamBuilder(
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
                                              title: Text(
                                                userModel.username,
                                                style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12.sp),
                                              ),
                                              subtitle: Text(
                                                DateFormat('dd-MM-yyyy').format(userModel.memberSince),
                                                style: AppTextStyles.nunitoRegular.copyWith(fontSize: 10.sp),
                                              ),
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
                                                        style: AppTextStyles.nunitoBold.copyWith(
                                                          fontSize: 10.sp,
                                                          color: AppColors.primaryBlack,
                                                        ),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        backgroundColor: Colors.green,
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
                                          title: Text(
                                            group.groupName,
                                            style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12.sp),
                                          ),
                                          subtitle: Text(
                                            DateFormat('dd-MM-yyyy').format(group.createdAt),
                                            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 10.sp),
                                          ),
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
                                                    style: AppTextStyles.nunitoBold.copyWith(
                                                      fontSize: 10.sp,
                                                      color: AppColors.primaryBlack,
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                ),
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: Icon(Icons.share),
    );
  }
}
