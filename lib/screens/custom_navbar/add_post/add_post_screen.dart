import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/controllers/text_controllers.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/add_post/widgets/add_images.dart';
import 'package:terra_zero_waste_app/services/post_services.dart';
import 'package:terra_zero_waste_app/widgets/buttons.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h), // Add space before the "Select Image" text
            Row(
              children: [
                Image.asset(
                  'lib/assets/gif_icons/image_icon.gif',
                  height: 50.h,
                  width: 50.w,
                ),
                SizedBox(width: 10.w),
                Text("Select Image", style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
              ],
            ),
            SizedBox(height: 5.h), // Add space before the description text
            Text(
              "Choose an image from your gallery or take a new one.",
              style: AppTextStyles.nunitoRegular.copyWith(fontSize: 12, color: Colors.grey[900]),
            ),
            SizedBox(height: 10.h),
            AddImages(),
            SizedBox(height: 20.h),
            Row(
              children: [
                Image.asset(
                  'lib/assets/gif_icons/caption_icon.gif',
                  height: 50.h,
                  width: 50.w,
                ),
                SizedBox(width: 10.w),
                Text("Add Caption", style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
              ],
            ),
            SizedBox(height: 5.h), // Add space before the description text
            Text(
              "Write a caption for your post.",
              style: AppTextStyles.nunitoRegular.copyWith(fontSize: 12, color: Colors.grey[900]),
            ),
            SizedBox(height: 10.h),
            CustomTextInput(
              controller: AppTextController.postCaptionController,
              hintText: "Enter your caption...",
              maxLines: 3,
            ),
            SizedBox(height: 50.h),
            Consumer<LoadingController>(builder: (context, loadingController, child) {
              return loadingController.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    )
                  : PrimaryButton(
                      title: "Upload",
                      onPressed: () {
                        PostServices()
                            .uploadPost(
                          context: context,
                          caption: AppTextController.postCaptionController.text,
                          images: imageController.imageList,
                        )
                            .then((e) {
                          AppTextController().clearTextInput();
                          setState(() {
                            imageController.imageList!.clear();
                          });
                        });
                      },
                    );
            })
          ],
        ),
      ),
    );
  }
}
