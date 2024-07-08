import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/widgets/show_options_for_image_picking.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../controllers/image_controller.dart';


class CustomTextInput extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool? isSecureText;
  final int? maxLines;
  final Widget? suffixIcon;
  final TextInputType? inputType;

  const CustomTextInput(
      {super.key, this.hintText, this.controller, this.isSecureText, this.suffixIcon, this.maxLines, this.inputType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primaryWhite,
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.5),
        ),
      ),
      child: TextField(
        keyboardType: inputType ?? TextInputType.text,
        maxLines: maxLines ?? 1,
        obscureText: isSecureText ?? false,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTextStyles.nunitoRegular, 
          suffixIcon: suffixIcon,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}

class SearchTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String v)? onChange;

  const SearchTextInput({super.key, this.controller, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primaryWhite,
        border: Border.all(
          color: AppColors.primaryBlack.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChange ?? (v) {},
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          border: InputBorder.none,
          hintText: "Search here...",
          hintStyle: AppTextStyles.nunitoRegular, // Apply custom hint text style
          prefixIcon: const Icon(Icons.search),
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController msgController;
  final Function() onPressed;
  const ChatInput({super.key, required this.msgController, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    final loadingController = Provider.of<LoadingController>(context);

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: MediaQuery.viewInsetsOf(context).bottom + 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: Get.width * 0.78,
            child: CustomTextInput(
              controller: msgController,
              suffixIcon: GestureDetector(
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
                child: Icon(Icons.add_a_photo_outlined),
              ),
              hintText: "Type Something",
            ),
          ),
          Container(
            height: 50.h,
            width: 55.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryBlack),
              borderRadius: BorderRadius.circular(10),
              color: AppColors.primaryColor.withOpacity(.2),
            ),
            child: Center(
              child: GestureDetector(
                onTap: onPressed,
                child: loadingController.isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.primaryWhite))
                    : Icon(Icons.send),
              ),
            ),
          )
        ],
      ),
    );
  }
}
