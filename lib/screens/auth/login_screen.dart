import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/controllers/text_controllers.dart';
import 'package:terra_zero_waste_app/screens/auth/forgot_password_screen.dart';
import 'package:terra_zero_waste_app/screens/auth/signup_screen.dart';
import 'package:terra_zero_waste_app/screens/auth/widgets/auth_footer_widget.dart';
import 'package:terra_zero_waste_app/services/auth_services.dart';
import 'package:terra_zero_waste_app/widgets/buttons.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

import '../../constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              SizedBox(height: 20.h),
              Text("Welcome Back!", style: AppTextStyles.mainTextStyle),
              SizedBox(height: 10.h),
              CustomTextInput(
                controller: AppTextController.emailController,
                hintText: "E-mail",
              ),
              SizedBox(height: 13.h),
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
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ForgotPasswordScreen());
                  },
                  child: Text("Forgot Password?", style: AppTextStyles.nunitoBold.copyWith(fontSize: 14, letterSpacing: 1.2, color: Colors.red[800])),
                ),
              ),
              SizedBox(height: 30.h),
              Consumer<LoadingController>(builder: (context, loadingController, child) {
                return loadingController.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor),
                      )
                    : PrimaryButton(
                        title: "Login",
                        onPressed: () {
                          AuthServices()
                              .login(
                            context: context,
                            email: AppTextController.emailController.text,
                            password: AppTextController.passwordController.text,
                          )
                              .whenComplete(() {
                            AppTextController().clearTextInput();
                          });
                        },
                      );
              }),
              SizedBox(height: 25.h),
              AuthFooterWidget(
                title: "Don't have an account",
                screenName: "Sign Up",
                titleStyle: AppTextStyles.nunitoBold.copyWith(
                  fontSize: 16.sp,
                  color: Colors.blue,
                ),
                onPressed: () {
                  Get.to(() => SignUpScreen());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
