import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
          Expanded(
            child: Container(
              color: Colors.white, // Ensure the background is white
              child: ListView(
                children: [
                  CustomListTile(
                    iconPath: 'edit_profile_icon.gif', // Replace with your file path in Firebase Storage
                    title: "Edit Profile",
                    onPressed: () {
                      Get.to(() => EditProfileScreen(
                          userModel: userController.userModel!));
                    },
                  ),
                  CustomListTile(
                    iconPath: 'chatbot_icon.gif', // Replace with your file path in Firebase Storage
                    title: "TERRA Chatbot",
                    onPressed: () {
                      Get.to(() => ChatbotPage());
                    },
                  ),
                  CustomListTile(
                    iconPath: 'earth_banner_icon.gif', // Replace with your file path in Firebase Storage
                    title: "TERRA Activities",
                    onPressed: () {
                      Get.to(() => HomePageActivities());
                    },
                  ),
                  SizedBox(height: 180.h), // Added space here
                  Divider(color: Colors.grey[300]),
                  CustomListTile(
                    iconPath: 'log_out_icon.gif', // Replace with your file path in Firebase Storage
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
          ),
        ],
      ),
    );
  }
}

class CustomListTile extends StatefulWidget {
  final String iconPath;
  final String title;
  final VoidCallback onPressed;

  const CustomListTile({
    required this.iconPath,
    required this.title,
    required this.onPressed,
  });

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  String? _iconUrl;

  @override
  void initState() {
    super.initState();
    _loadGifIcon();
  }

  Future<void> _loadGifIcon() async {
    try {
      String url = await FirebaseStorage.instance
          .ref(widget.iconPath)
          .getDownloadURL();
      setState(() {
        _iconUrl = url;
      });
    } catch (e) {
      print('Error loading GIF icon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _iconUrl != null
          ? Image.network(
              _iconUrl!,
              width: 48.w,
              height: 48.h,
            )
          : CircularProgressIndicator(),
      title: Text(
        widget.title,
        style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp),
      ),
      onTap: widget.onPressed,
    );
  }
}
