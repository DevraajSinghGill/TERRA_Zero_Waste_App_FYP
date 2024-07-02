import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/controllers/text_controllers.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/widgets/profile_image_portion.dart';
import 'package:terra_zero_waste_app/services/user_profile_services.dart';
import 'package:terra_zero_waste_app/widgets/buttons.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

import '../../../controllers/image_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const EditProfileScreen({super.key, required this.userModel});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();

    AppTextController.usernameController.text = widget.userModel.username;
    AppTextController.aboutController.text = widget.userModel.about;
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white), // Set font color to white
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h), 
              ProfileImagePortion(userModel: widget.userModel),
              SizedBox(height: 30),
              Text("UserName", style: AppTextStyles.nunitoBold.copyWith(fontSize: 16, color: AppColors.primaryBlack)),
              SizedBox(height: 5),
              CustomTextInput(
                controller: AppTextController.usernameController,
                hintText: widget.userModel.username,
              ),
              SizedBox(height: 20),
              Text("About", style: AppTextStyles.nunitoBold.copyWith(fontSize: 16, color: AppColors.primaryBlack)),
              SizedBox(height: 5),
              CustomTextInput(
                controller: AppTextController.aboutController,
                hintText: widget.userModel.about,
                maxLines: 3,
              ),
              SizedBox(height: 50.h),
              Consumer<LoadingController>(builder: (context, loadingController, child) {
                return loadingController.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor),
                      )
                    : PrimaryButton(
                        onPressed: () {
                          UserProfileServices()
                              .updateProfile(
                            context: context,
                            username: AppTextController.usernameController.text.isEmpty
                                ? widget.userModel.username
                                : AppTextController.usernameController.text,
                            about: AppTextController.aboutController.text.isEmpty
                                ? widget.userModel.about
                                : AppTextController.aboutController.text,
                            image: imageController.selectedImage,
                          )
                              .whenComplete(() {
                            AppTextController().clearTextInput();
                            imageController.removeUploadPicture();
                          });
                        },
                        title: "Update",
                      );
              })
            ],
          ),
        ),
      ),
    );
  }
}
