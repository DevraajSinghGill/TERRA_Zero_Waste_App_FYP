import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../controllers/post_controller.dart';
import '../../../../models/post_model.dart';

class PostTab extends StatelessWidget {
  const PostTab({super.key});

  @override
  Widget build(BuildContext context) {
    final postController = Provider.of<PostController>(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Posts", style: AppTextStyles.nunitoBold.copyWith(fontSize: 15)),
          SizedBox(height: 10.h),
          if (postController.isLoading)
            Center(child: CircularProgressIndicator())
          else
            postController.errorMessage != null
                ? Center(child: Text(postController.errorMessage!))
                : postController.myPostModelList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 70),
                          child: Text(
                            "No Posts Found",
                            style: AppTextStyles.nunitoBold.copyWith(fontSize: 15, color: AppColors.primaryColor),
                          ),
                        ),
                      )
                    : Expanded(
                        child: GridView.builder(
                          itemCount: postController.myPostModelList.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            PostModel postModel = postController.myPostModelList[index];
                            return Container(
                              height: 100,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: postModel.postImages[0],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
        ],
      ),
    );
  }
}
