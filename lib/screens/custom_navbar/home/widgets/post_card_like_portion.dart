import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../models/post_model.dart';
import '../../../../services/post_services.dart';

class PostCardLikePortion extends StatelessWidget {
  final String postId;
  const PostCardLikePortion({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('posts').doc(postId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            PostModel _post = PostModel.fromMap(snapshot.data!);

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    PostServices.likePost(postId, _post.likedBy);
                  },
                  child: Icon(
                    _post.likedBy.contains(FirebaseAuth.instance.currentUser!.uid) ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 25.sp,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  _post.likedBy.length.toString(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
    );
  }
}
