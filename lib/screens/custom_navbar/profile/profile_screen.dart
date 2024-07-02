import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/post_controller.dart';
import 'package:terra_zero_waste_app/controllers/user_controller.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/tabs/followers_tab.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/tabs/following_tab.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/tabs/post_tab.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/widgets/custom_toggle_tab.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/widgets/profile_header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context).userModel;
    final postController = Provider.of<PostController>(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeaderWidget(),
            SizedBox(height: 20.h),
            Divider(),
            SizedBox(height: 20.h),
            CustomToggleTab(
                tabList: [
                  "${postController.myPostModelList.length.toString()}\nPosts",
                  "${userController!.following.length.toString()}\nFollowing",
                  "${userController.followers.length.toString()}\nFollowers"
                ],
                currentIndex: _selectedIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }),
            SizedBox(height: 30.h),
            if (_selectedIndex == 0) ...{
              PostTab(),
            },
            if (_selectedIndex == 1) ...{
              Expanded(child: FollowingTab()),
            },
            if (_selectedIndex == 2) ...{
              Expanded(child: FollowersTab()),
            }
          ],
        ),
      ),
    );
  }
}
