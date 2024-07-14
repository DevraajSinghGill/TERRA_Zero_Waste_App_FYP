import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_main.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_profle_page.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_approved_page.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_qr_page.dart';
import 'package:terra_zero_waste_app/screens/auth/login_screen.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  final Future<void> _initialization = Future.delayed(Duration(seconds: 1));
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> screensList = [
    const AdminPendingPage(),
    const AdminQrPage(),
    const AdminProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.forward(from: 0.0); // Reset and start the animation from the beginning
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => LoginScreen());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                getAppTitle(_currentIndex),
                style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout,
                ),
                SizedBox(width: 10.w),
              ],
            ),
            bottomNavigationBar: Container(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              child: GNav(
                rippleColor: Colors.lightBlueAccent,
                hoverColor: Colors.lightBlueAccent,
                haptic: true,
                tabBorderRadius: 20,
                tabActiveBorder: Border.all(color: Colors.white, width: 2),
                tabBorder: Border.all(color: Colors.transparent, width: 1),
                tabShadow: [],
                curve: Curves.easeOutExpo,
                duration: Duration(milliseconds: 360),
                gap: 0,
                color: Colors.white,
                activeColor: Colors.white,
                iconSize: 24,
                tabBackgroundColor: Colors.lightBlue.withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                selectedIndex: _currentIndex,
                onTabChange: _onItemTapped,
                tabs: [
                  GButton(
                    icon: Icons.apps,
                    text: 'Tasks',
                    textStyle: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12.sp, color: Colors.white),
                  ),
                  GButton(
                    icon: Icons.qr_code,
                    text: 'QR Code',
                    textStyle: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12.sp, color: Colors.white),
                  ),
                  GButton(
                    icon: Icons.person,
                    text: 'Profile',
                    textStyle: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12.sp, color: Colors.white),
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
        return "Chat";
      case 2:
        return "Profile";
      default:
        return "";
    }
  }
}
