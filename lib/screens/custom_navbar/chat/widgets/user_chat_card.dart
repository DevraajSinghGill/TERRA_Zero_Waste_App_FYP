import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:timeago/timeago.dart' as timeago;


import '../../../../constants/app_colors.dart';
import '../../../../models/user_model.dart';
import '../chat_main_screen.dart';

class UserChatCard extends StatelessWidget {
  final dynamic data;
  final UserModel userModel;
  const UserChatCard({super.key, required this.userModel, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Get.to(() => ChatMainScreen(userId: userModel.userId));
          },
          leading: userModel.image == ""
              ? CircleAvatar(
                  backgroundColor: AppColors.primaryBlack,
                  radius: 30.r,
                  child: Text(
                    userModel.username[0].toUpperCase(),
                    style: AppTextStyles.nunitoBold.copyWith(
                      color: AppColors.primaryColor,
                      fontSize: 22.sp,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 30.r,
                  backgroundImage: NetworkImage(userModel.image),
                ),
          title: Text(
            userModel.username,
            style: AppTextStyles.nunitoSemiBod,
          ),
          subtitle: Text(
            data['msg'],
            style: AppTextStyles.nunitoMedium.copyWith(
              color: AppColors.primaryGrey,
            ),
          ),
          trailing: Text(
            timeago.format(data['createdAt'].toDate()),
            style: AppTextStyles.nunitoRegular.copyWith(
              color: AppColors.primaryGrey,
              fontSize: 12.sp,
            ),
          ),
        ),
        Divider(height: 10),
      ],
    );
  }
}
