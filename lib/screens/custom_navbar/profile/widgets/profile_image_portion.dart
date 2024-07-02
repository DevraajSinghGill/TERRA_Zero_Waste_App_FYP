import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';

import '../../../../constants/app_colors.dart';
import '../../../../controllers/image_controller.dart';
import '../../../../widgets/show_options_for_image_picking.dart';

class ProfileImagePortion extends StatelessWidget {
  final UserModel userModel;
  const ProfileImagePortion({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return Center(
      child: Stack(
        children: [
          if (imageController.selectedImage == null && userModel.image == "")
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 50.sp,
                ),
              ),
            ),
          if (imageController.selectedImage == null && userModel.image != "")
            CircleAvatar(
              radius: 50.r,
              backgroundImage: NetworkImage(userModel.image),
            ),
          if (imageController.selectedImage != null)
            CircleAvatar(
              radius: 55.r,
              backgroundImage: FileImage(imageController.selectedImage!),
            ),
          Positioned(
            right: 0.w,
            bottom: 5.h,
            child: Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryWhite,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x190013CE),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  )
                ],
              ),
              child: GestureDetector(
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
                child: Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
