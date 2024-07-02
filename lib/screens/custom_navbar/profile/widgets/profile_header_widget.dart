import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_assets.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../controllers/user_controller.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context).userModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h), // Added SizedBox to increase space above profile picture and username
        Row(
          children: [
            userController!.image == ""
                ? Center(
                    child: CircleAvatar(
                      radius: 25.h,
                      backgroundColor: AppColors.primaryGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(AppAssets.personIcon, color: AppColors.primaryWhite),
                      ),
                    ),
                  )
                : Center(
                    child: CircleAvatar(
                      radius: 25.h,
                      backgroundImage: NetworkImage(userController.image),
                    ),
                  ),
            SizedBox(width: 30.w), // Increased width to add more space before username
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userController.username,
                  style: AppTextStyles.nunitoBold.copyWith(fontSize: 16),
                ),
                SizedBox(height: 5.h),
                Text(
                  "Member Since " + DateFormat('dd-MM-yyyy').format(userController.memberSince),
                  style: AppTextStyles.nunitoBold.copyWith(fontSize: 12, color: AppColors.primaryBlack.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          userController.about,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }
}
