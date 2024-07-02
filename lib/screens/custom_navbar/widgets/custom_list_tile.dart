import 'package:flutter/material.dart';

import '../../../constants/app_text_styles.dart';

class CustomListTile extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Function()? onPressed;
  const CustomListTile({super.key, this.icon, this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title!, style: AppTextStyles.nunitoBold.copyWith(fontSize: 16)),
          onTap: onPressed ?? () {},
        ),
        Divider(height: 0.5),
      ],
    );
  }
}
