import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../../../../constants/app_colors.dart';

class CustomToggleTab extends StatelessWidget {
  final int currentIndex;
  final Function(int v) onSelected;
  final List<String> tabList;
  const CustomToggleTab({super.key, required this.currentIndex, required this.onSelected, required this.tabList});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlutterToggleTab(
        width: 85.w,
        borderRadius: 8,
        height: 50,
        selectedIndex: currentIndex,
        selectedBackgroundColors: [AppColors.primaryColor],
        selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        unSelectedTextStyle: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
        labels: tabList,
        selectedLabelIndex: onSelected,
        isScroll: false,
      ),
    );
  }
}
