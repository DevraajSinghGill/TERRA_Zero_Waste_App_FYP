import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/models/group_chat_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/post_detail_screen.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/search/other_user_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../constants/app_colors.dart';
import '../../../../../models/post_model.dart';
import '../../../widgets/image_full_view.dart';

class GroupChatPortion extends StatelessWidget {
  final String groupId;
  const GroupChatPortion({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groupChats')
            .doc(groupId)
            .collection('messages')
            .orderBy('sendingTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No Msg Found", style: AppTextStyles.mainTextStyle),
            );
          }
          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              GroupChatModel groupChatModel = GroupChatModel.fromDoc(snapshot.data!.docs[index]);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => OtherUserDetailScreen(userId: groupChatModel.userId));
                      },
                      child: groupChatModel.userImage == ""
                          ? CircleAvatar(
                              backgroundColor: AppColors.primaryBlack,
                              radius: 22.r,
                              child: Center(
                                child: Text(
                                  groupChatModel.username[0].toUpperCase(),
                                  style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 16.sp, color: AppColors.primaryColor),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 22.r,
                              backgroundImage: NetworkImage(groupChatModel.userImage),
                            ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color.fromARGB(255, 32, 79, 102).withOpacity(0.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  groupChatModel.username,
                                  style: AppTextStyles.nunitoSemiBod,
                                ),
                                Text(
                                  timeago.format(groupChatModel.sendingTime),
                                  style: AppTextStyles.rubikMedium.copyWith(color: Colors.grey.shade900),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            if (groupChatModel.image != "")
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => ImageFullView(image: groupChatModel.image));
                                },
                                child: SizedBox(
                                  height: 120.h,
                                  width: Get.width,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(groupChatModel.image, fit: BoxFit.cover),
                                  ),
                                ),
                              )
                            else if (groupChatModel.postId != "")
                              StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('posts').doc(groupChatModel.postId).snapshots(),
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
                                            style: AppTextStyles.rubikMedium.copyWith(fontSize: 12.sp),
                                          ),
                                          SizedBox(height: 5),
                                          SizedBox(
                                            height: 120.h,
                                            width: 250.w,
                                            child: Image.network(postModel.postImages[0], fit: BoxFit.cover),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                            else
                              Text(groupChatModel.msg, style: AppTextStyles.nunitoRegular),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
