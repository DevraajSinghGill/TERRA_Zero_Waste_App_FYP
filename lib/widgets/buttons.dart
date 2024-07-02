import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SocialButton extends StatelessWidget {
  final String? image, title;
  final Function()? onPressed;
  const SocialButton({super.key, this.image, this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        height: 50.h,
        width: Get.width - 70,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.primaryWhite, boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withOpacity(0.5),
            blurRadius: 2.0,
          )
        ]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 25.h,
                width: 25.w,
                child: Image.asset(image!),
              ),
              SizedBox(width: 20.w),
              Text(
                title!,
                style: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.primaryBlack,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final Function()? onPressed;
  final String? title;
  final double? height;
  const PrimaryButton({super.key, this.onPressed, this.title, this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        height: height ?? 50.h,
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primaryColor,
        ),
        child: Center(
          child: Text(
            "$title".toUpperCase(),
            style: AppTextStyles.nunitoBold.copyWith(
              color: AppColors.primaryWhite,
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String title;
  final Function()? onPressed;
  final Color? btnColor, textColor;
  const SecondaryButton({super.key, required this.title, this.btnColor, this.textColor, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: btnColor ?? AppColors.primaryBlack,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              title,
              style: TextStyle(
                color: textColor ?? AppColors.primaryWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
