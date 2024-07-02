import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';

class ImageSendingPortion extends StatelessWidget {
  final ImageController imageController;
  final Function() onSendBtnClick;
  final bool isLoading;
  const ImageSendingPortion({super.key, required this.imageController, required this.onSendBtnClick, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(imageController.selectedImage!.path)),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {},
                child: GestureDetector(
                  onTap: () {
                    imageController.removeUploadPicture();
                  },
                  child: Icon(Icons.close),
                ),
              ),
              SizedBox(width: 15.w),
              FloatingActionButton(
                onPressed: onSendBtnClick,
                child: isLoading
                    ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
