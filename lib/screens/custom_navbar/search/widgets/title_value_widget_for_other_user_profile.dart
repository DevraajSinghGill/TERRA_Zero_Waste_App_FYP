import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class TitleValueWidgetForOtherUserProfile extends StatelessWidget {
  final String title, value;
  const TitleValueWidgetForOtherUserProfile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.nunitoMedium.copyWith(
            color: AppColors.primaryBlack.withOpacity(0.5),
          ),
        ),
        Text(value, style: AppTextStyles.nunitoBold.copyWith(fontSize: 15)),
        SizedBox(height: 5.h),
      ],
    );
  }
}
