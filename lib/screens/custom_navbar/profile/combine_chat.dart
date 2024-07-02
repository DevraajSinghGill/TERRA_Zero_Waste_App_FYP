import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra_zero_waste_app/constants/app_assets.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/widgets/user_chat_card.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

import '../../../constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../chat/group/group_chat_screen.dart';

class CombineChatScreen extends StatefulWidget {
  const CombineChatScreen({super.key});

  @override
  State<CombineChatScreen> createState() => _CombineChatScreenState();
}

class _CombineChatScreenState extends State<CombineChatScreen> {
  TextEditingController _searchController = TextEditingController();

  Stream<List<DocumentSnapshot>> _combineChatStreams() {
    var userChatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('uids', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    var groupChatsStream = FirebaseFirestore.instance
        .collection('groupChats')
        .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return CombineLatestStream.list([userChatsStream, groupChatsStream]).map((list) => list.expand((i) => i).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            children: [
              SearchTextInput(
                controller: _searchController,
                onChange: (v) {
                  setState(() {});
                },
              ),
              SizedBox(height: 10),
              StreamBuilder(
                stream: _combineChatStreams(),
                builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
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
                        String otherUserId = chat['uids'].firstWhere((id) => id != FirebaseAuth.instance.currentUser!.uid);

                        return StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('users').doc(otherUserId).snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            var userModel = snap.data!;

                            if (_searchController.text.isEmpty ||
                                userModel['username'].toString().toLowerCase().contains(_searchController.text.toLowerCase())) {
                              return UserChatCard(
                                userModel: UserModel.fromMap(userModel),
                                data: chat,
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        );
                      } else if (chat.reference.path.contains('groupChats')) {
                        if (_searchController.text.isEmpty ||
                            chat['groupName'].toString().toLowerCase().contains(_searchController.text.toLowerCase())) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(AppAssets.personIcon),
                            ),
                            title: Text(chat['groupName'], style: TextStyle(fontSize: 18)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GroupChatScreen(groupId: chat['groupId'])),
                              );
                            },
                            subtitle: Text('lastMsg'),
                          );
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
            ],
          ),
        ),
      ),
    );
  }
}
