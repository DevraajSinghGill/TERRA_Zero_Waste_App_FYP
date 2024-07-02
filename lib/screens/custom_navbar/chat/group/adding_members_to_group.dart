import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/adding_group_information_screen.dart';
import 'package:terra_zero_waste_app/widgets/buttons.dart';

class AddingMembersToGroup extends StatefulWidget {
  const AddingMembersToGroup({super.key});

  @override
  State<AddingMembersToGroup> createState() => _AddingMembersToGroupState();
}

class _AddingMembersToGroupState extends State<AddingMembersToGroup> {
  List _userIds = [FirebaseAuth.instance.currentUser!.uid];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Members"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No User Found"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              UserModel userModel = UserModel.fromMap(snapshot.data!.docs[index]);
              return StatefulBuilder(builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: userModel.image == ""
                            ? CircleAvatar(
                                radius: 30.r,
                                child: Center(
                                  child: Text(userModel.username[0]),
                                ),
                              )
                            : CircleAvatar(
                                radius: 30.r,
                                backgroundImage: NetworkImage(userModel.image),
                              ),
                        title: Text(userModel.username, style: AppTextStyles.nunitoBold.copyWith(fontSize: 15)),
                        subtitle: Text(userModel.email),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (_userIds.contains(userModel.userId)) {
                              _userIds.remove(userModel.userId);
                            } else {
                              _userIds.add(userModel.userId);
                            }
                            setState(() {});
                          },
                          child: _userIds.contains(userModel.userId) ? Text("Remove") : Text("Add"),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                        ),
                      ),
                      Divider(height: 0.2),
                    ],
                  ),
                );
              });
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: PrimaryButton(
          onPressed: () {
            Get.to(() => AddingGroupInformationScreen(userIds: _userIds));
          },
          title: "Next",
        ),
      ),
    );
  }
}
