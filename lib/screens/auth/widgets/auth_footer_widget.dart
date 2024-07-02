import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_text_styles.dart';

class AuthFooterWidget extends StatelessWidget {
  final String? title, screenName;
  final Function()? onPressed;
  const AuthFooterWidget({super.key, this.title, this.screenName, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$title?  ",
            style: AppTextStyles.nunitoRegular.copyWith(
              fontSize: 14.sp,
            ),
          ),
          Text(
            "$screenName",
            style: AppTextStyles.quicksandSemiBold.copyWith(
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
