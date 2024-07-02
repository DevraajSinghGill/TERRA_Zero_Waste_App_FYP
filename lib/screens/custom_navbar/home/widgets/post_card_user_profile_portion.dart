import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/search/other_user_detail_screen.dart';
import 'package:terra_zero_waste_app/services/post_services.dart';
import 'package:terra_zero_waste_app/widgets/alert_dialog_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants/app_assets.dart';
import '../edit_post_screen.dart';

class PostCardUserProfilePortion extends StatelessWidget {
  final PostModel post;
  const PostCardUserProfilePortion({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.to(() => OtherUserDetailScreen(userId: post.userId));
      },
      leading: post.userImage == ""
          ? CircleAvatar(
              radius: 22.r,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(AppAssets.personIcon),
              ),
            )
          : CircleAvatar(
              radius: 22.r,
              backgroundImage: NetworkImage(post.userImage),
            ),
      contentPadding: EdgeInsets.zero,
      title: Text(
        post.username,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        timeago.format(post.createdAt),
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
        ),
      ),
      trailing: post.userId == FirebaseAuth.instance.currentUser!.uid
          ? PopupMenuButton<String>(
              onSelected: (String choice) {
                if (choice == 'Edit') {
                  Get.to(() => EditPostScreen(postModel: post));
                } else if (choice == 'Delete') {
                  showCustomAlertDialog(
                    context: context,
                    content: "Are you sure to delete this post?",
                    onPressed: () {
                      PostServices.deletePost(post.postId);
                      Get.back();
                    },
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: Icon(Icons.more_vert),
            )
          : SizedBox(),
    );
  }
}
