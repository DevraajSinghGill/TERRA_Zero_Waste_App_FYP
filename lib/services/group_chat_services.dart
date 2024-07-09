import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/models/group_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_chat_screen.dart';
import 'package:terra_zero_waste_app/services/storage_services.dart';
import 'package:uuid/uuid.dart';

import '../controllers/loading_controller.dart';
import '../models/group_chat_model.dart';
import '../widgets/custom_msg.dart';
import 'image_compress_services.dart';

class GroupChatServices {
  Future<void> createGroup({
    required BuildContext context,
    required String title,
    required String description,
    required List userIds,
    File? image,
  }) async {
    if (title.isEmpty) {
      showCustomMsg(context, "Group title required");
    } else if (description.isEmpty) {
      showCustomMsg(context, "Description required");
    } else {
      try {
        Provider.of<LoadingController>(context, listen: false).setLoading(true);

        var groupId = const Uuid().v4();
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        String? imageUrl;
        if (image != null) {
          File _compressImage = await compressImage(image);
          imageUrl = await StorageServices().uploadImageToDb(_compressImage);
        }
        GroupModel groupModel = GroupModel(
          groupId: groupId,
          groupImage: imageUrl ?? "",
          groupName: title,
          lastMsg: "Group Created",
          createdAt: DateTime.now(),
          userIds: userIds,
          adminIds: [FirebaseAuth.instance.currentUser!.uid],
          groupCreatorId: FirebaseAuth.instance.currentUser!.uid,
          groupCreatorName: snapshot['username'],
          lastMsgTime: DateTime.now(),
        );
        await FirebaseFirestore.instance.collection('groupChats').doc(groupId).set(groupModel.toMap());
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        Get.to(() => GroupChatScreen(groupId: groupId));
      } on FirebaseException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        showCustomMsg(context, e.message!);
      }
    }
  }

  Future<void> sendMsgInGroup({
    BuildContext? context,
    String? msg,
    File? image,
    String? postId,
    required String groupId,
  }) async {
    if (msg!.isEmpty && image == null) {
      showCustomMsg(context!, "Write something or select an image");
      return;
    }
    try {
      Provider.of<LoadingController>(context!, listen: false).setLoading(true);

      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      DocumentSnapshot groupChatSnap = await FirebaseFirestore.instance.collection('groupChats').doc(groupId).get();

      String? imageUrl;
      if (image != null) {
        File? _compressImage = await compressImage(image);
        imageUrl = await StorageServices().uploadImageToDb(_compressImage);
      }
      if (groupChatSnap.exists) {
        await FirebaseFirestore.instance.collection('groupChats').doc(groupId).update({
          'lastMsg': msg,
          'lastMsgTime': DateTime.now(),
        });
      }

      GroupChatModel groupChatModel = GroupChatModel(
        userId: FirebaseAuth.instance.currentUser!.uid,
        username: snap['username'],
        userImage: snap['image'],
        msg: msg,
        image: imageUrl ?? "",
        postId: postId!,
        sendingTime: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupId)
          .collection('messages')
          .add(groupChatModel.toMap());
      Provider.of<LoadingController>(context, listen: false).setLoading(false);
    } on FirebaseException catch (e) {
      Provider.of<LoadingController>(context!, listen: false).setLoading(false);
      showCustomMsg(context, e.message!);
    }
  }

  Future<void> updateGroup({
    required BuildContext context,
    required String groupId,
    required String title,
    required String description,
    XFile? image,
  }) async {
    if (title.isEmpty) {
      showCustomMsg(context, "Group title required");
      return;
    }
    if (description.isEmpty) {
      showCustomMsg(context, "Description required");
      return;
    }
    try {
      Provider.of<LoadingController>(context, listen: false).setLoading(true);

      String? imageUrl;
      if (image != null) {
        File _compressImage = await compressImage(File(image.path));
        imageUrl = await StorageServices().uploadImageToDb(_compressImage);
      }

      Map<String, dynamic> updateData = {
        'groupName': title,
        'description': description,
        'lastMsgTime': DateTime.now(),
      };
      if (imageUrl != null) {
        updateData['groupImage'] = imageUrl;
      }

      await FirebaseFirestore.instance.collection('groupChats').doc(groupId).update(updateData);

      Provider.of<LoadingController>(context, listen: false).setLoading(false);
      showCustomMsg(context, "Group details updated successfully");
    } on FirebaseException catch (e) {
      Provider.of<LoadingController>(context, listen: false).setLoading(false);
      showCustomMsg(context, e.message!);
    }
  }

  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('groupChats').doc(groupId).get();
      return docSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      print(e.toString());
      return {};
    }
  }
}
