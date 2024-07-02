import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:terra_zero_waste_app/constants/app_assets.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';

import '../../../services/user_profile_services.dart';
import '../../../widgets/buttons.dart';
import '../chat/chat_main_screen.dart';

class OtherUserDetailScreen extends StatefulWidget {
  final String userId;
  const OtherUserDetailScreen({super.key, required this.userId});

  @override
  State<OtherUserDetailScreen> createState() => _OtherUserDetailScreenState();
}

class _OtherUserDetailScreenState extends State<OtherUserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          UserModel userModel = UserModel.fromMap(snapshot.data!);
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),  // Add space here
                        Row(
                          children: [
                            userModel.image == ""
                                ? CircleAvatar(
                                    radius: 35.r,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(AppAssets.personIcon),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 50.r,
                                    backgroundImage: NetworkImage(userModel.image),
                                  ),
                            SizedBox(width: 20.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userModel.username,
                                  style: AppTextStyles.nunitoSemiBod.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "Member Since : ${DateFormat('dd-MM-yyyy').format(userModel.memberSince)}",
                                  style: AppTextStyles.nunitoBold.copyWith(fontSize: 10, color: AppColors.primaryGrey),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          userModel.about,
                          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16)  // Apply custom font style
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,  // Center the buttons
                            children: [
                              SecondaryButton(
                                title: "Chat",
                                textStyle: AppTextStyles.nunitoBold.copyWith(color: Colors.white), // Custom font style
                                onPressed: () {
                                  Get.to(() => ChatMainScreen(userId: userModel.userId));
                                },
                              ),
                              SizedBox(width: 20),
                              SecondaryButton(
                                title: userModel.followers.contains(FirebaseAuth.instance.currentUser!.uid) ? "Following" : "Follow",
                                btnColor: AppColors.primaryColor,
                                textStyle: AppTextStyles.nunitoBold.copyWith(color: Colors.white), // Custom font style
                                onPressed: () {
                                  UserProfileServices.FollowAndUnFollowUser(context, widget.userId);
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 10.h),
                        Text("Posts", style: AppTextStyles.nunitoBold.copyWith(fontSize: 18)),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: Get.height * 0.5,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('posts').where('userId', isEqualTo: userModel.userId).snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text("No Post Uploaded", style: AppTextStyles.nunitoBold),
                                );
                              }
                              return GridView.builder(
                                itemCount: snapshot.data!.docs.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  PostModel postModel = PostModel.fromMap(snapshot.data!.docs[index]);
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: postModel.postImages[0],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
