import 'package:flutter/material.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class PendingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        'Pending tasks will be displayed here.',
        style: AppTextStyles.nunitoRegular,
      ),
    );
  }
}
