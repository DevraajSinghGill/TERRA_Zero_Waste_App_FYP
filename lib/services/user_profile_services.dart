import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/services/image_compress_services.dart';
import 'package:terra_zero_waste_app/services/storage_services.dart';
import 'package:terra_zero_waste_app/widgets/custom_msg.dart';

class UserProfileServices {
  Future<void> updateProfile({
    required BuildContext context,
    required String username,
    required String about,
    File? image,
  }) async {
    try {
      Provider.of<LoadingController>(context, listen: false).setLoading(true);

      String? imageUrl;

      if (image != null) {
        File? _compressImage = await compressImage(image);
        imageUrl = await StorageServices().uploadImageToDb(_compressImage);
      }

      Map<String, dynamic> data = {
        'username': username,
        'about': about,
      };

      if (imageUrl != null) {
        data['image'] = imageUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(data);

      Provider.of<LoadingController>(context, listen: false).setLoading(false);
      showCustomMsg(context, "Changes Save");
      Get.back();
    } on FirebaseException catch (e) {
      Provider.of<LoadingController>(context, listen: false).setLoading(false);
      showCustomMsg(context, e.message!);
    }
  }

  static FollowAndUnFollowUser(BuildContext context, String userId) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (snap['followers'].contains(FirebaseAuth.instance.currentUser!.uid)) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'followers': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
          'following': FieldValue.arrayRemove([userId])
        });
        showCustomMsg(context, "You are unfollow this user");
      } else {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'followers': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
          'following': FieldValue.arrayUnion([userId])
        });
        showCustomMsg(context, "You are now following this user");
      }
    } on FirebaseException catch (e) {
      showCustomMsg(context, e.message!);
    }
  }
}
