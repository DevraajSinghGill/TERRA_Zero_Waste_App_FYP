import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_colors.dart';
import '../../../../controllers/image_controller.dart';
import '../../../../widgets/show_options_for_image_picking.dart';

class ImageUploadingWidgetForPost extends StatelessWidget {
  const ImageUploadingWidgetForPost({super.key});

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return imageController.selectedImage == null
        ? Container(
            height: Get.height * 0.2,
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryColor, width: 0.5),
              color: AppColors.primaryGrey.withOpacity(0.3),
            ),
            child: Center(
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
                child: Icon(Icons.add_a_photo_outlined, size: 35),
              ),
            ),
          )
        : Container(
            height: Get.height * 0.2,
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryColor, width: 0.5),
              color: AppColors.primaryGrey.withOpacity(0.3),
              image: DecorationImage(
                image: FileImage(File(imageController.selectedImage!.path)),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    imageController.removeUploadPicture();
                  },
                  child: Icon(Icons.close_outlined, color: Colors.red),
                ),
              ),
            ),
          );
  }
}
