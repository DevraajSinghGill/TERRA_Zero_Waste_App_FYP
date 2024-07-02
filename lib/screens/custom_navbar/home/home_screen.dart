import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/post_controller.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/widgets/post_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postController = Provider.of<PostController>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // SearchTextInput(),
          postController.isLoading
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                ))
              : postController.errorMessage != null
                  ? Center(child: Text(postController.errorMessage!))
                  : postController.postListModel.isEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.only(top: 250),
                          child: Text("No Post Found", style: AppTextStyles.nunitoBold),
                        ))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: postController.postListModel.length,
                            itemBuilder: (context, index) {
                              return PostCard(post: postController.postListModel[index]);
                            },
                          ),
                        )
        ],
      ),
    );
  }
}
