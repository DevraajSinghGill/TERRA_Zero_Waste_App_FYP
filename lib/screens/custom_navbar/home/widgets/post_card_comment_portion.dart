import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';

import '../../../../constants/app_assets.dart';
import '../comment_screen.dart';

class PostCardCommentPortion extends StatelessWidget {
  final PostModel post;
  const PostCardCommentPortion({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CommentScreen(postModel: post));
      },
      child: SizedBox(
        child: Row(
          children: [
            SizedBox(
              height: 25,
              width: 25,
              child: Image.asset(AppAssets.chatIcon),
            ),
            SizedBox(width: 5),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(post.postId)
                  .collection('comments')
                  .orderBy('commentTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    "0",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                int commentCount = snapshot.data!.docs.length;
                return Text(
                  commentCount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
