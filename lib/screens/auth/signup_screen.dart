import 'dart:io';
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'lib/assets/images/background_login_page.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: size.width,
            height: size.height,
            color: Colors.black.withOpacity(0.5),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15.h),
                  SafeArea(
                    child: Center(
                      child: Text(
                        "Register Your Account",
                        style: AppTextStyles.nunitoBold.copyWith(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ProfileImagePickingWidget(),
                  SizedBox(height: 10.h),
                  CustomTextInput(
                    controller: AppTextController.usernameController,
                    hintText: "Username",
                  ),
                  SizedBox(height: 10.h),
                  CustomTextInput(
                    controller: AppTextController.emailController,
                    hintText: "Email",
                  ),
                  SizedBox(height: 10.h),
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
                      child: Icon(
                          _isVisible ? Icons.visibility_off : Icons.visibility,
                          size: 20.r,
                          color: AppColors.primaryGrey),
                    ),
                  ),
                  SizedBox(height: 10.h),
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
                      child: Icon(
                          _isConfirmPassVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20.r,
                          color: AppColors.primaryGrey),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextInput(
                    controller: AppTextController.aboutController,
                    hintText: "About",
                    maxLines: 2,
                  ),
                  SizedBox(height: 10.h),
                  Consumer<LoadingController>(
                      builder: (context, loadingController, child) {
                    return loadingController.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryColor))
                        : Column(
                            children: [
                              PrimaryButton(
                                onPressed: () async {
                                  await AuthServices().signUp(
                                    context: context,
                                    image: imageController.selectedImage,
                                    username: AppTextController
                                        .usernameController.text,
                                    about:
                                        AppTextController.aboutController.text,
                                    email:
                                        AppTextController.emailController.text,
                                    password: AppTextController
                                        .passwordController.text,
                                    confirmPassword: AppTextController
                                        .confirmPasswordController.text,
                                  );
                                },
                                title: "Sign Up",
                              ),
                              SizedBox(height: 6.h),
                              GoogleSignInButton(),
                            ],
                          );
                  }),
                  SizedBox(height: 12.h),
                  AuthFooterWidget(
                    onPressed: () {
                      Get.back();
                    },
                    title: "Already have an account ?",
                    screenName: "Login",
                    titleStyle: AppTextStyles.nunitoBold.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                    screenNameStyle: AppTextStyles.nunitoBold.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final response = await AuthServices().signInWithGoogle();
        Get.snackbar('Google Sign-In', response,
            snackPosition: SnackPosition.BOTTOM);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up with',
              style: AppTextStyles.nunitoBold
                  .copyWith(color: AppColors.primaryColor),
            ),
            SizedBox(width: 5.w),
            Image.asset(
              'lib/assets/images/google_sign_in.png', // Make sure you have this asset in your project
              height: 25.h,
              width: 25.w,
            ),
          ],
        ),
      ),
    );
  }
}
