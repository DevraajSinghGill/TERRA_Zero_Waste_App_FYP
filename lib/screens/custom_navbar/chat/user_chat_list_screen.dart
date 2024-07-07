import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/constants/chat_stream.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/widgets/group_chat_card.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/widgets/user_chat_card.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

import '../../../constants/app_colors.dart';
import '../../../models/group_model.dart';
import '../../../models/user_model.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/adding_members_to_group.dart';

class UserChatListScreen extends StatefulWidget {
  const UserChatListScreen({super.key});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            SizedBox(height: 20), // Add space between the top and search bar
            SearchTextInput(
              controller: _searchController,
              onChange: (v) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => AddingMembersToGroup());
                  },
                  child: Text(
                    "Make a Group Chat",
                    style: AppTextStyles.nunitoSemiBod.copyWith(
                      fontSize: 18,
                      color: AppColors.primaryWhite,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: ChatStream().combineChatStreams(),
                builder:
                    (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryColor),
                    );
                  }

                  var chats = snapshot.data!;
                  return ListView.builder(
                    itemCount: chats.length,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      var chat = chats[index];

                      if (chat.reference.path.contains('chats')) {
                        String otherUserId = chat['uids'].firstWhere(
                            (id) => id != FirebaseAuth.instance.currentUser!.uid);

                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(otherUserId)
                              .snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            var userModel = snap.data!;

                            if (_searchController.text.isEmpty ||
                                userModel['username']
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                        _searchController.text.toLowerCase())) {
                              return UserChatCard(
                                  userModel: UserModel.fromMap(userModel),
                                  data: chat);
                            } else {
                              return SizedBox();
                            }
                          },
                        );
                      } else if (chat.reference.path.contains('groupChats')) {
                        GroupModel group = GroupModel.fromMap(chat);
                        if (_searchController.text.isEmpty ||
                            group.groupName
                                .toString()
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase())) {
                          return GroupChatCard(group: group);
                        } else {
                          return SizedBox();
                        }
                      } else {
                        return SizedBox.shrink();
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
  }
}
