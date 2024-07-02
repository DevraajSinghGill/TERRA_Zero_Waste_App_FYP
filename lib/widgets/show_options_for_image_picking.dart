import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';

showOptionsForImagePicking({
  required BuildContext context,
  required Function() onCameraClicked,
  required Function() onGalleryClicked,
}) {
  return showDialog(
    context: context,
    builder: (_) {
      return SimpleDialog(
        title: Center(
          child: Text(
            "Pick Image",
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Divider(height: 0.1, thickness: 0.1),
          ListTile(
            onTap: onCameraClicked,
            leading: Icon(Icons.camera_alt, size: 20),
            title: Text(
              "Camera",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(thickness: 0.3, height: 0.2),
          ListTile(
            onTap: onGalleryClicked,
            leading: Icon(Icons.photo, size: 20),
            title: Text(
              "Gallery",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 0.2, thickness: 0.3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () {
                Get.back();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
