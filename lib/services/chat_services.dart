import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/models/message_model.dart';

import '../services/image_compress_services.dart';
import '../services/storage_services.dart';
import '../widgets/custom_msg.dart';

class ChatServices {
  Future<void> sendMsg({
    required BuildContext context,
    required String msg,
    required String docId,
    required String userId,
    File? image,
    String? postId,
  }) async {
    if (msg.isEmpty) {
      showCustomMsg(context, 'write something');
    } else {
      try {
        Provider.of<LoadingController>(context, listen: false).setLoading(true);

        DocumentSnapshot chatSnap = await FirebaseFirestore.instance.collection('chats').doc(docId).get();
        DocumentSnapshot userSnap =
            await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
        String? imageUrl;
        if (image != null) {
          File? _compressImage = await compressImage(image);
          imageUrl = await StorageServices().uploadImageToDb(_compressImage);
        }

        if (chatSnap.exists) {
          await FirebaseFirestore.instance.collection('chats').doc(docId).update({
            'msg': msg,
            'createdAt': DateTime.now(),
          });
        } else {
          await FirebaseFirestore.instance.collection('chats').doc(docId).set({
            'uids': [FirebaseAuth.instance.currentUser!.uid, userId],
            'msg': msg,
            'chatId': docId,
            'createdAt': DateTime.now(),
          });
        }
        MessageModel messageModel = MessageModel(
          msg: msg,
          image: imageUrl ?? "",
          senderId: FirebaseAuth.instance.currentUser!.uid,
          username: userSnap['username'],
          userImage: userSnap['image'],
          sendingTime: DateTime.now(),
          postId: postId!,
        );
        await FirebaseFirestore.instance.collection('chats').doc(docId).collection('messages').add(messageModel.toMap());
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
      } on FirebaseException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        showCustomMsg(context, e.message!);
      }
    }
  }
}
