import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

showCustomAlertDialog({required BuildContext context, required String content, required Function() onPressed}) {
  showDialog(
    context: context,
    builder: (_) {
      return CupertinoAlertDialog(
        title: Text(
          "Wait",
          style: AppTextStyles.mainTextStyle,
        ),
        content: Text(
          content,
          style: AppTextStyles.nunitoRegular,
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
            },
            child: Text(
              "No",
              style: AppTextStyles.nunitoMedium.copyWith(color: Colors.red),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: onPressed,
            child: Text(
              "Yes",
              style: AppTextStyles.nunitoSemiBod.copyWith(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}
