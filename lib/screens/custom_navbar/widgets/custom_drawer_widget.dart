import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/chatbot/chatbot_page.dart';
import 'package:terra_zero_waste_app/constants/app_assets.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/user_controller.dart';
import 'package:terra_zero_waste_app/gamification/home_page_activites.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/edit_profile_screen.dart';
import '../../../services/auth_services.dart';
import '../../../widgets/alert_dialog_widget.dart';
import 'custom_list_tile.dart';

class CustomDrawerWidget extends StatelessWidget {
  const CustomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    return Drawer(
      child: Column(
        children: [
          Container(
            height: Get.height * 0.3,
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundImage: userController.userModel!.image == ""
                        ? AssetImage(AppAssets.personIcon)
                        : NetworkImage(userController.userModel!.image)
                            as ImageProvider,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  userController.userModel!.username,
                  style: AppTextStyles.nunitoBold
                      .copyWith(fontSize: 20.sp, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  "Member Since: " +
                      DateFormat('dd-MM-yyyy')
                          .format(userController.userModel!.memberSince),
                  style: AppTextStyles.nunitoBold
                      .copyWith(fontSize: 10.sp, color: Colors.white70),
                )
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Divider(color: Colors.grey[300]),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                CustomListTile(
                  icon: 'lib/assets/gif_icons/edit_profile_icon.gif',
                  title: "Edit Profile",
                  onPressed: () {
                    Get.to(() => EditProfileScreen(
                        userModel: userController.userModel!));
                  },
                ),
                CustomListTile(
                  icon: 'lib/assets/gif_icons/chatbot_icon.gif',
                  title: "TERRA Chatbot",
                  onPressed: () {
                    Get.to(() => ChatbotPage());
                  },
                ),
                CustomListTile(
                  icon: 'lib/assets/gif_icons/earth_banner_icon.gif',
                  title: "TERRA Activities",
                  onPressed: () {
                    Get.to(() => HomePageActivities());
                  },
                ),
                SizedBox(height: 200.h), // Added space here
                Divider(color: Colors.grey[300]),
                CustomListTile(
                  icon: 'lib/assets/gif_icons/log_out_icon.gif',
                  title: "LogOut",
                  onPressed: () {
                    showCustomAlertDialog(
                      context: context,
                      content: "Are you sure to logout?",
                      onPressed: () {
                        AuthServices.signOut();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final dynamic icon; // Updated to dynamic to handle both IconData and String
  final String title;
  final VoidCallback onPressed;

  const CustomListTile({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon is String
          ? Image.asset(icon,
              width: 48.w, height: 48.h) // Increased size for GIF icons
          : Icon(icon,
              size: 48.sp,
              color: Colors.black), // Increased size for regular icons
      title: Text(
        title,
        style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp),
      ),
      onTap: onPressed,
    );
  }
}
