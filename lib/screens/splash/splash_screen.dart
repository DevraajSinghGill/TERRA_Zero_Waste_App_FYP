import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/screens/auth/login_screen.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/custom_navbar.dart';
import 'package:terra_zero_waste_app/widgets/logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(Duration(seconds: 4), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Get.offAll(() => CustomNavBar());
      } else {
        Get.offAll(() => LoginScreen());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LogoWidget(),
    );
  }
}
