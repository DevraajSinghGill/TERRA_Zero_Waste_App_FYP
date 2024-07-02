import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class LogoWidget extends StatefulWidget {
  final double? height, width;
  const LogoWidget({super.key, this.height, this.width});

  @override
  _LogoWidgetState createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true);

    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: widget.height ?? 350,
              width: widget.width ?? 400,
              child: Image(
                image: AssetImage("lib/assets/gif_icons/organic_splash.gif"),
              ),
            ),
            FadeTransition(
              opacity: _animation,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome to',
                        style:
                            AppTextStyles.nunitoBold.copyWith(fontSize: 24.sp),
                      ),
                      Text(
                        'TERRA Zero Waste!',
                        style:
                            AppTextStyles.nunitoBold.copyWith(fontSize: 24.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
