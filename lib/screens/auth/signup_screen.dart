import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/controllers/text_controllers.dart';
import 'package:terra_zero_waste_app/screens/auth/widgets/auth_footer_widget.dart';
import 'package:terra_zero_waste_app/screens/auth/widgets/profile_image_picking_widget.dart';
import 'package:terra_zero_waste_app/services/auth_services.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/text_inputs.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isVisible = true;
  bool _isConfirmPassVisible = true;
  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              SafeArea(
                child: Center(
                  child: Text(
                    "Register Your Account",
                    style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ProfileImagePickingWidget(),
              SizedBox(height: 20.h),
              CustomTextInput(
                controller: AppTextController.usernameController,
                hintText: "username",
              ),
              SizedBox(height: 12.h),
              CustomTextInput(
                controller: AppTextController.emailController,
                hintText: "Email",
              ),
              SizedBox(height: 12.h),
              CustomTextInput(
                controller: AppTextController.passwordController,
                hintText: "Password",
                isSecureText: _isVisible,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  child: Icon(_isVisible ? Icons.visibility_off : Icons.visibility, size: 20.r, color: AppColors.primaryGrey),
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextInput(
                controller: AppTextController.confirmPasswordController,
                hintText: "Confirm Password",
                isSecureText: _isConfirmPassVisible,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isConfirmPassVisible = !_isConfirmPassVisible;
                    });
                  },
                  child: Icon(_isConfirmPassVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20.r, color: AppColors.primaryGrey),
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextInput(
                controller: AppTextController.aboutController,
                hintText: "About",
                maxLines: 3,
              ),
              SizedBox(height: 25.h),
              Consumer<LoadingController>(builder: (context, loadingController, child) {
                return loadingController.isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                    : PrimaryButton(
                        onPressed: () {
                          AuthServices()
                              .signUp(
                            context: context,
                            username: AppTextController.usernameController.text,
                            email: AppTextController.emailController.text,
                            password: AppTextController.passwordController.text,
                            confirmPassword: AppTextController.confirmPasswordController.text,
                            image: imageController.selectedImage,
                            about: AppTextController.aboutController.text,
                          )
                              .whenComplete(() {
                            AppTextController().clearTextInput();
                            imageController.removeUploadPicture();
                          });
                        },
                        title: "Sign Up",
                      );
              }),
              SizedBox(height: 15.h),
              AuthFooterWidget(
                onPressed: () {
                  Get.back();
                },
                title: "Already have an account",
                screenName: "Login",
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}
