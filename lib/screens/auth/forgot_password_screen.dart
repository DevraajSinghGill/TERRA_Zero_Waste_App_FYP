import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/controllers/text_controllers.dart';
import 'package:terra_zero_waste_app/services/auth_services.dart';

import '../../constants/app_text_styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/text_inputs.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.sp),
            const Center(
              child: SafeArea(
                child: LogoWidget(),
              ),
            ),
            SizedBox(height: 30.h),
            Text("Reset your password", style: AppTextStyles.nunitoSemiBod.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text("Please Enter your email to get link for password reset",
                style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 14)),
            SizedBox(height: 40.h),
            CustomTextInput(
              controller: AppTextController.emailController,
              hintText: "E-mail",
            ),
            SizedBox(height: 50.h),
            Consumer<LoadingController>(builder: (context, loadingController, child) {
              return loadingController.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    )
                  : PrimaryButton(
                      onPressed: () {
                        AuthServices().resetPassword(context, AppTextController.emailController.text).whenComplete(() {
                          AppTextController().clearTextInput();
                        });
                      },
                      title: "Reset",
                    );
            })
          ],
        ),
      ),
    );
  }
}
