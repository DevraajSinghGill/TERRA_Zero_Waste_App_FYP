import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AuthFooterWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final String screenName;
  final TextStyle titleStyle;
  final TextStyle screenNameStyle;

  AuthFooterWidget({
    required this.onPressed,
    required this.title,
    required this.screenName,
    required this.titleStyle,
    required this.screenNameStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: RichText(
          text: TextSpan(
            text: "$title ",
            style: titleStyle,
            children: [
              TextSpan(
                text: screenName,
                style: screenNameStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
