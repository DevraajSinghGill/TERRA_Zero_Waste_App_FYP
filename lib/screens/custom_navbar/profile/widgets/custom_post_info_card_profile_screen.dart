import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class CustomPostInfoCard extends StatelessWidget {
  final String? length;
  final String? title;
  final bool? isLineRequired;
  const CustomPostInfoCard({super.key, this.length, this.title, this.isLineRequired});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              length!,
              style: AppTextStyles.nunitoBold.copyWith(
                fontSize: 14,
              ),
            ),
            Text(
              title!,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(width: 30.w),
        isLineRequired == false
            ? SizedBox()
            : Container(
                height: Get.height * 0.06,
                width: 1.5,
                color: AppColors.primaryBlack,
              ),
      ],
    );
  }
}
