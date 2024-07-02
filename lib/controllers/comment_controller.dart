import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/controllers/text_controllers.dart';
import 'package:terra_zero_waste_app/models/comment_model.dart';
import 'package:terra_zero_waste_app/widgets/custom_msg.dart';

class CommentController extends ChangeNotifier {
  Future<void> commentOnPost({
    required BuildContext context,
    required String comment,
    required String postId,
  }) async {
    if (comment.isEmpty) {
      showCustomMsg(context, "Write something");
    } else {
      try {
        Provider.of<LoadingController>(context, listen: false).setLoading(true);

        DocumentSnapshot snap =
            await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();

        CommentModel commentModel = CommentModel(
          postId: postId,
          userId: FirebaseAuth.instance.currentUser!.uid,
          username: snap['username'],
          userImage: snap['image'],
          comment: comment,
          commentTime: DateTime.now(),
        );

        await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').add(commentModel.toMap());
        Provider.of<LoadingController>(context, listen: false).setLoading(false);

        FocusScope.of(context).unfocus();
        AppTextController().clearTextInput();
        notifyListeners();
      } on FirebaseException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        showCustomMsg(context, e.message!);
      }
    }
  }
}
