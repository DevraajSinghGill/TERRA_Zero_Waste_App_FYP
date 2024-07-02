import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostCardImagePortion extends StatelessWidget {
  final List postImages;
  const PostCardImagePortion({super.key, required this.postImages});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.2,
      width: Get.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: postImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: postImages[index],
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
                width: Get.width * 0.8, // Adjust the width as needed
              ),
            ),
          );
        },
      ),
    );
  }
}
