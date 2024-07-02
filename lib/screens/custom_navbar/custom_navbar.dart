import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:terra_zero_waste_app/constants/app_assets.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/constants/lists.dart';
import 'package:terra_zero_waste_app/controllers/post_controller.dart';
import 'package:terra_zero_waste_app/controllers/user_controller.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/adding_members_to_group.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/widgets/custom_drawer_widget.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/widgets/custom_tabbar_widget.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late Future<void> _initialization;
  GlobalKey<ScaffoldState> key = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initialization = initialize();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  Future<void> initialize() async {
    await getUserInformation();
    await getAllPosts();
    await getAllUsers();
    await getAllMyPosts();
  }

  Future<void> getUserInformation() async {
    await Provider.of<UserController>(context, listen: false)
        .getUserInformation();
  }

  Future<void> getAllPosts() async {
    await Provider.of<PostController>(context, listen: false).getAllPosts();
  }

  Future<void> getAllUsers() async {
    await Provider.of<UserController>(context, listen: false).getAllUsers();
  }

  Future<void> getAllMyPosts() async {
    await Provider.of<PostController>(context, listen: false).getAllMyPost();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            key: _currentIndex == 0 ? key : null,
            drawer: _currentIndex == 0 ? CustomDrawerWidget() : null,
            appBar: AppBar(
              title: Text(
                getAppTitle(_currentIndex),
                style: AppTextStyles.nunitoBold.copyWith(color: Colors.white), // Apply custom text style here with white color
              ),
              actions: [
                SizedBox(width: 10.w),
              ],
            ),
            bottomNavigationBar: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              child: GNav(
                rippleColor: const Color.fromARGB(255, 58, 162, 61),
                hoverColor: const Color.fromARGB(255, 9, 66, 11),
                haptic: true,
                tabBorderRadius: 20, // Increase border radius
                tabActiveBorder: Border.all(
                    color: Colors.green, width: 2), // Add green border
                tabBorder: Border.all(color: Colors.transparent, width: 1),
                tabShadow: [],
                curve: Curves.easeOutExpo,
                duration: Duration(milliseconds: 900),
                gap: 0,
                color: Colors.grey[800],
                activeColor: const Color.fromARGB(255, 9, 66, 11),
                iconSize: 20, // Increase icon size
                tabBackgroundColor:
                    const Color.fromARGB(255, 2, 121, 6).withOpacity(0.1),
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15), // Increase padding
                selectedIndex: _currentIndex,
                onTabChange: _onItemTapped,
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                    textStyle: TextStyle(fontSize: 12.sp), // Set font size here
                  ),
                  GButton(
                    icon: Icons.search,
                    text: 'Search',
                    textStyle: TextStyle(fontSize: 10.sp), // Set font size here
                  ),
                  GButton(
                    icon: Icons.add,
                    text: 'Post',
                    textStyle: TextStyle(fontSize: 10.sp), // Set font size here
                  ),
                  GButton(
                    icon: Icons.chat,
                    text: 'Chat',
                    textStyle: TextStyle(fontSize: 10.sp), // Set font size here
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                    textStyle: TextStyle(fontSize: 10.sp), // Set font size here
                  ),
                ],
              ),
            ),
            body: FadeTransition(
              opacity: _animation,
              child: screensList[_currentIndex],
            ),
          );
        }
      },
    );
  }

  String getAppTitle(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Search";
      case 2:
        return "Post";
      case 3:
        return "Chat";
      case 4:
        return "Profile";
      default:
        return "";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
