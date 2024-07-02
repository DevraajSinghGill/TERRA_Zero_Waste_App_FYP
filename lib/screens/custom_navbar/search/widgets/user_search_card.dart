import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';

import '../../../../constants/app_assets.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../other_user_detail_screen.dart';

class UserSearchCard extends StatelessWidget {
  final UserModel userModel;
  const UserSearchCard({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(top: 10),
          child: ListTile(
            leading: userModel.image == ""
                ? CircleAvatar(
                    radius: 22.r,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.asset(AppAssets.personIcon),
                    ),
                  )
                : CircleAvatar(
                    radius: 22.r,
                    backgroundImage: NetworkImage(userModel.image),
                  ),
            title: Text(
              userModel.username,
              style: AppTextStyles.nunitoBold.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Member Since: " + DateFormat('dd-MM-yyyy').format(userModel.memberSince),
              style: AppTextStyles.nunitoMedium.copyWith(fontSize: 10),
            ),
            trailing: userModel.userId != FirebaseAuth.instance.currentUser!.uid
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      onPressed: () {
                        Get.to(() => OtherUserDetailScreen(userId: userModel.userId));
                      },
                      child: Text(
                        "View Detail",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: AppColors.primaryBlack,
                      ),
                    ),
                  )
                : SizedBox(),
          ),
          color: AppColors.primaryWhite,
        )
      ],
    );
  }
}
