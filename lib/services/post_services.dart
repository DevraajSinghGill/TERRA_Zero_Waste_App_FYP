import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/custom_navbar.dart';
import 'package:terra_zero_waste_app/services/image_compress_services.dart';
import 'package:terra_zero_waste_app/widgets/custom_msg.dart';
import 'package:uuid/uuid.dart';

class PostServices {
  Future<void> uploadPost({
    required BuildContext context,
    List<File>? images,
    required String caption,
  }) async {
    if (images!.isEmpty) {
      showCustomMsg(context, "Post images required");
    } else if (caption.isEmpty) {
      showCustomMsg(context, "Caption Needed");
    } else {
      try {
        var postId = Uuid().v4();
        Provider.of<LoadingController>(context, listen: false).setLoading(true);

        DocumentSnapshot userSnap =
            await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
        List<String> _imageUrls = [];
        for (var image in images) {
          File _compressImage = await compressImage(image);
          FirebaseStorage fs = FirebaseStorage.instance;
          Reference ref = await fs.ref().child(DateTime.now().millisecondsSinceEpoch.toString());
          await ref.putFile(File(_compressImage.path));
          String imageUrl = await ref.getDownloadURL();
          _imageUrls.add(imageUrl);
        }

        PostModel postModel = PostModel(
          postId: postId,
          postImages: _imageUrls,
          caption: caption,
          userId: FirebaseAuth.instance.currentUser!.uid,
          userImage: userSnap['image'],
          username: userSnap['username'],
          createdAt: DateTime.now(),
          likedBy: [],
        );

        await FirebaseFirestore.instance.collection('posts').doc(postId).set(postModel.toMap());
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Post Uploaded',
          desc: 'Your Post is Uploaded Successfully',
          btnOkOnPress: () {
            Get.offAll(() => CustomNavBar());
          },
        )..show();
      } on FirebaseException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        showCustomMsg(context, e.message!);
      }
    }
  }

  Future<void> updatePost({
    required BuildContext context,
    required List images,
    String? caption,
    required String postId,
  }) async {
    try {
      Provider.of<LoadingController>(context, listen: false).setLoading(true);

      String? postImageUrl;

      List<String> imageUrls = [];

      for (var image in images) {
        File _compressImage = await compressImage(image);
        FirebaseStorage fs = FirebaseStorage.instance;
        Reference ref = await fs.ref().child(DateTime.now().millisecondsSinceEpoch.toString());
        await ref.putFile(File(_compressImage.path));
        String imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      Map<String, dynamic> postData = {
        'caption': caption,
      };

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'caption': caption,
        'postImage': FieldValue.arrayUnion(imageUrls),
      });
      Provider.of<LoadingController>(context, listen: false).setLoading(false);
      Get.back();
      showCustomMsg(context, "Post Updated");
    } on FirebaseException catch (e) {
      Provider.of<LoadingController>(context, listen: false).setLoading(false);
      showCustomMsg(context, e.message!);
    }
  }

  static likePost(String postId, List postList) async {
    try {
      if (postList.contains(FirebaseAuth.instance.currentUser!.uid)) {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likedBy': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likedBy': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }
    } on FirebaseException catch (e) {
      throw Exception("Error :$e");
    }
  }

  static deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    } on FirebaseException catch (e) {
      throw Exception("Error :$e");
    }
  }
}
