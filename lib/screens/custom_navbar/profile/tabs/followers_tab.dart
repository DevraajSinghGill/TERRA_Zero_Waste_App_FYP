import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/user_controller.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/search/widgets/user_search_card.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../models/user_model.dart';

class FollowersTab extends StatelessWidget {
  const FollowersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Followers", style: AppTextStyles.nunitoBold.copyWith(fontSize: 15)),
        userController.userModel!.followers.isEmpty
            ? Center(
                child: Text("No User Found", style: AppTextStyles.nunitoBold.copyWith(color: AppColors.primaryColor)),
              )
            : Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: userController.userModel!.followers)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text("No User Found"),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        UserModel userModel = UserModel.fromMap(snapshot.data!.docs[index]);
                        return UserSearchCard(userModel: userModel);
                      },
                    );
                  },
                ),
              ),
      ],
    );
  }
}
