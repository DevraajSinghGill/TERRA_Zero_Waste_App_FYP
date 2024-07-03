import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:terra_zero_waste_app/constants/app_assets.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';

import '../../../models/user_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel postModel;
  const PostDetailScreen({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post Detail",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text("User Detail", style: AppTextStyles.nunitoBold.copyWith(fontSize: 16)),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(postModel.userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                }
                UserModel userModel = UserModel.fromMap(snapshot.data!);
                return Column(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              userModel.image == ""
                                  ? CircleAvatar(
                                      radius: 30.r,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Image.asset(AppAssets.personIcon),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 30.r,
                                      backgroundImage: NetworkImage(userModel.image),
                                    ),
                              SizedBox(width: 20.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userModel.username,
                                    style: AppTextStyles.nunitoRegular.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "Member Since : ${DateFormat('dd-MM-yyyy').format(userModel.memberSince)}",
                                    style: AppTextStyles.nunitoBold.copyWith(fontSize: 14, color: AppColors.primaryGrey),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            userModel.about,
                            style: AppTextStyles.nunitoMedium.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            Divider(),
            SizedBox(height: 20),
            Text("Post Contents", style: AppTextStyles.nunitoBold.copyWith(fontSize: 16)),
            SizedBox(height: 10),
            SizedBox(
              height: Get.height * 0.3,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: postModel.postImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10, right: 20),
                    height: Get.height * 0.25,
                    width: Get.width * .9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: NetworkImage(postModel.postImages[index]), fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.6,
                  ),
                  child: Text(postModel.caption, style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                ),
                Spacer(),
                Text(
                  "Posted On: " + DateFormat('dd-MM-yyyy').format(postModel.createdAt),
                  style: AppTextStyles.nunitoBold.copyWith(fontSize: 10, color: AppColors.primaryGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
