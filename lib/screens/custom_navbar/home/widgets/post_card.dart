import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/post_card_comment_portion.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/post_card_image_portion.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/post_card_like_portion.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/post_card_user_profile_portion.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/post_sending_portion.dart';

import '../../../../models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Map<String, bool> isLoadingMap = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffc4c4c4).withOpacity(0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostCardUserProfilePortion(post: widget.post),
            Text(
              widget.post.caption,
              style: AppTextStyles.nunitoBold.copyWith(fontSize: 14),
            ),
            SizedBox(height: 10.h),
            PostCardImagePortion(postImages: widget.post.postImages),
            SizedBox(height: 15.h),
            Row(
              children: [
                PostCardLikePortion(postId: widget.post.postId),
                SizedBox(width: 20.w),
                PostCardCommentPortion(post: widget.post),
                Spacer(),
                PostSendingPortion(postId: widget.post.postId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
