import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/comment_card.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../controllers/comment_controller.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/text_controllers.dart';
import '../../../models/comment_model.dart';
import '../../../models/post_model.dart';

class CommentScreen extends StatelessWidget {
  final PostModel postModel;
  const CommentScreen({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    final commentController = Provider.of<CommentController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Comments",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white), // Using AppTextStyles
        ),
        backgroundColor: Colors.green[900], // Changed to green[800]
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(postModel.postId)
            .collection('comments')
            .orderBy("commentTime")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Comment Found!",
                style: AppTextStyles.nunitoBold.copyWith(color: AppColors.primaryColor), // Using AppTextStyles
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              CommentModel commentModel = CommentModel.fromMap(snapshot.data!.docs[index]);
              return CommentCard(
                commentModel: commentModel,
                commentId: snapshot.data!.docs[index].id,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom + 10, left: 15, right: 15),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: AppTextController.commentController,
                decoration: InputDecoration(
                  hintText: "Write Something",
                  hintStyle: AppTextStyles.nunitoMedium, // Apply the hint style
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Consumer<LoadingController>(builder: (context, loadingController, child) {
              return CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.primaryColor.withOpacity(.6),
                child: GestureDetector(
                  onTap: () {
                    commentController.commentOnPost(
                      context: context,
                      comment: AppTextController.commentController.text,
                      postId: postModel.postId,
                    );
                  },
                  child: loadingController.isLoading
                      ? CircularProgressIndicator(color: AppColors.primaryWhite)
                      : Icon(Icons.send, color: AppColors.primaryWhite, size: 25),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
