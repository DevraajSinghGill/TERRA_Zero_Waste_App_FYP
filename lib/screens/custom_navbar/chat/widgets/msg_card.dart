import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/post_detail_screen.dart';

import '../../../../constants/app_colors.dart';
import '../../../../models/message_model.dart';
import '../../../../constants/app_text_styles.dart';
import '../../widgets/image_full_view.dart';

class MsgCard extends StatelessWidget {
  final MessageModel messageModel;
  const MsgCard({super.key, required this.messageModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5),
      child: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.7,
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid
                          ? Colors.blueGrey
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment
                      children: [
                        if (messageModel.image != "")
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ImageFullView(image: messageModel.image));
                            },
                            child: SizedBox(
                              height: 80.h,
                              width: 150.w,
                              child: Image.network(messageModel.image, fit: BoxFit.cover),
                            ),
                          )
                        else if (messageModel.postId != "")
                          StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('posts').doc(messageModel.postId).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                PostModel postModel = PostModel.fromMap(snapshot.data!);
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => PostDetailScreen(postModel: postModel));
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        postModel.caption,
                                        style: AppTextStyles.nunitoRegular.copyWith(
                                          color: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12.sp, // Smaller font size
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        height: 80.h,
                                        width: 150.w,
                                        child: Image.network(postModel.postImages[0], fit: BoxFit.cover),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                );
                              })
                        else
                          Text(
                            messageModel.msg,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid ? Colors.white : Colors.black,
                              fontSize: 12.sp, // Smaller font size
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                messageModel.userImage == ""
                    ? CircleAvatar(
                        radius: 22.sp,
                        backgroundColor: AppColors.primaryBlack,
                        child: Text(
                          messageModel.username[0].toUpperCase(),
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 16.sp, // Smaller font size
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 22.sp,
                        backgroundImage: NetworkImage(messageModel.userImage),
                      ),
              ],
            )
          : Row(
              children: [
                messageModel.userImage == ""
                    ? CircleAvatar(
                        radius: 20.sp,
                        backgroundColor: AppColors.primaryBlack,
                        child: Text(
                          messageModel.username[0].toUpperCase(),
                          style: AppTextStyles.nunitoRegular.copyWith(
                            fontSize: 16.sp, // Smaller font size
                            color: AppColors.primaryColor,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 20.sp,
                        backgroundImage: NetworkImage(messageModel.userImage),
                      ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.7,
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid
                          ? Colors.blueGrey
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment
                      children: [
                        if (messageModel.image != "")
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ImageFullView(image: messageModel.image));
                            },
                            child: SizedBox(
                              height: 80.h,
                              width: 150.w,
                              child: Image.network(messageModel.image, fit: BoxFit.cover),
                            ),
                          )
                        else if (messageModel.postId != "")
                          StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('posts').doc(messageModel.postId).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                PostModel postModel = PostModel.fromMap(snapshot.data!);
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => PostDetailScreen(postModel: postModel));
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        postModel.caption,
                                        style: AppTextStyles.nunitoRegular.copyWith(
                                          color: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 12.sp, // Smaller font size
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(
                                        height: 80.h,
                                        width: 150.w,
                                        child: Image.network(postModel.postImages[0], fit: BoxFit.cover),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                );
                              })
                        else
                          Text(
                            messageModel.msg,
                            style: AppTextStyles.nunitoRegular.copyWith(
                              color: messageModel.senderId == FirebaseAuth.instance.currentUser!.uid ? Colors.white : Colors.black,
                              fontSize: 12.sp, 
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
