import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

import '../../../../../../../constants/app_colors.dart';
import '../../../../../../../controllers/image_controller.dart';

class AddImages extends StatefulWidget {
  const AddImages({super.key});

  @override
  State<AddImages> createState() => _AddImagesState();
}

class _AddImagesState extends State<AddImages> {
  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _showPickImageDialog(context, imageController);
                },
                child: Icon(Icons.add_circle, color: AppColors.primaryColor, size: 24),
              ),
            ),
          ),
          SizedBox(width: 23.w),
          Expanded(
            child: Container(
              height: 60.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageController.imageList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(imageController.imageList![index]),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                imageController.imageList!.removeAt(index);
                                setState(() {});
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 2, right: 3),
                                  child: Icon(Icons.clear, color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showPickImageDialog(BuildContext context, ImageController imageController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Select Image',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text('From Gallery', style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                  onTap: () {
                    Navigator.of(context).pop();
                    imageController.pickImage(ImageSource.gallery).then((value) {
                      if (imageController.selectedImage != null) {
                        imageController.imageList!.add(File(imageController.selectedImage!.path));
                      }
                    });
                  },
                ),
                Divider(),
                SizedBox(height: 10),
                GestureDetector(
                  child: Text('From Camera', style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                  onTap: () {
                    Navigator.of(context).pop();
                    imageController.pickImage(ImageSource.camera).then((value) {
                      if (imageController.selectedImage != null) {
                        imageController.imageList!.add(File(imageController.selectedImage!.path));
                      }
                    });
                  },
                ),
                Divider(),
                SizedBox(height: 10),
                GestureDetector(
                  child: Text('Cancel', style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
