import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomTabWidget extends StatelessWidget {
  final String image, title;
  final Function()? onPressed;
  final Color? selectedColor;
  const CustomBottomTabWidget({super.key, required this.image, required this.title, this.onPressed, this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 18.h,
            width: 25.w,
            child: Image.asset(image, color: selectedColor),
          ),
          SizedBox(height: 3.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: selectedColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
