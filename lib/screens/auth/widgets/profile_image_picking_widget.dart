import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../controllers/image_controller.dart';
import '../../../widgets/show_options_for_image_picking.dart';

class ProfileImagePickingWidget extends StatelessWidget {
  const ProfileImagePickingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          imageController.selectedImage != null
              ? CircleAvatar(
                  radius: 45.r,
                  backgroundImage: FileImage(File(imageController.selectedImage!.path)),
                )
              : CircleAvatar(
                  radius: 45.r,
                  backgroundColor: AppColors.primaryGrey.withOpacity(0.5),
                  child: Icon(Icons.person, size: 50.sp, color: AppColors.primaryWhite),
                ),
          Positioned(
            bottom: 5,
            right: 0,
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: imageController.selectedImage != null ? AppColors.primaryColor : AppColors.primaryWhite,
                border: Border.all(color: AppColors.primaryColor),
              ),
              child: imageController.selectedImage != null
                  ? GestureDetector(
                      onTap: () {
                        imageController.removeUploadPicture();
                      },
                      child: Icon(Icons.close, color: Colors.red, size: 18),
                    )
                  : GestureDetector(
                      onTap: () {
                        showOptionsForImagePicking(
                          context: context,
                          onCameraClicked: () {
                            Get.back();
                            imageController.pickImage(ImageSource.camera);
                          },
                          onGalleryClicked: () {
                            Get.back();
                            imageController.pickImage(ImageSource.gallery);
                          },
                        );
                      },
                      child: Icon(Icons.camera_alt, color: AppColors.primaryColor, size: 18),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
