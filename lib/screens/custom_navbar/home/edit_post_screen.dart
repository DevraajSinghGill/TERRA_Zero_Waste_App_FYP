import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/models/post_model.dart';
import 'package:terra_zero_waste_app/services/post_services.dart';
import 'package:terra_zero_waste_app/widgets/buttons.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel postModel;
  const EditPostScreen({super.key, required this.postModel});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  List _images = [];
  List<File> _newImageList = [];

  getImagesFromDb() async {
    _images = widget.postModel.postImages!;
  }

  @override
  void initState() {
    super.initState();
    _captionController.text = widget.postModel.caption;
    getImagesFromDb();
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add New Images", style: AppTextStyles.nunitoBold.copyWith(fontSize: 14.sp)),
            SizedBox(height: 10),

            Row(
              children: [
                Container(
                  height: 50.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(
                                child: Text(
                                  'Select Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: [
                                    GestureDetector(
                                      child: Text('From Gallery', style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        imageController.pickImage(ImageSource.gallery).then((value) {
                                          if (imageController.selectedImage != null) {
                                            _newImageList.add(File(imageController.selectedImage!.path));
                                          }
                                        });
                                      },
                                    ),
                                    Divider(),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      child: Text('From Camera', style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        imageController.pickImage(ImageSource.camera).then((value) {
                                          if (imageController.selectedImage != null) {
                                            _newImageList.add(File(imageController.selectedImage!.path));
                                          }
                                        });
                                      },
                                    ),
                                    Divider(),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      child: Text('Cancel', style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        // imageController.pickImage(ImageSource.gallery).then((value) {
                        //   _newImageList.add(File(imageController.selectedImage!.path));
                        // });
                      },
                      child: Icon(Icons.add_circle, color: AppColors.primaryColor, size: 24),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  height: 60,
                  width: Get.width - 100,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: _newImageList.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 10),
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_newImageList[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3, right: 3),
                            child: GestureDetector(
                              onTap: () async {
                                _newImageList.removeAt(index);
                                setState(() {});
                              },
                              child: Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text("Existing Images", style: AppTextStyles.nunitoBold.copyWith(fontSize: 14.sp)),
            SizedBox(height: 10),
            Container(
              height: 60,
              width: Get.width,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (ctx, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                          _images[index],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3, right: 3),
                        child: GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance.collection('posts').doc(widget.postModel.postId).update({
                              'postImage': FieldValue.arrayRemove([_images[index]]),
                            });
                            _images.removeAt(index);
                            setState(() {});
                          },
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // imageController.selectedImage != null
            //     ? Container(
            //         margin: EdgeInsets.symmetric(vertical: 15),
            //         height: Get.height * .3,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(10),
            //           image: DecorationImage(
            //             image: FileImage(File(imageController.selectedImage!.path)),
            //             fit: BoxFit.cover,
            //             colorFilter: ColorFilter.mode(AppColors.primaryBlack.withOpacity(0.2), BlendMode.srcATop),
            //           ),
            //         ),
            //         child: Align(
            //           alignment: Alignment.topRight,
            //           child: Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: CircleAvatar(
            //               backgroundColor: AppColors.primaryColor.withOpacity(0.7),
            //               child: GestureDetector(
            //                 onTap: () {
            //                   imageController.removeUploadPicture();
            //                 },
            //                 child: Icon(Icons.close, color: AppColors.primaryWhite),
            //               ),
            //             ),
            //           ),
            //         ),
            //       )
            //     : Container(
            //         margin: EdgeInsets.symmetric(vertical: 15),
            //         height: Get.height * .3,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(10),
            //           image: DecorationImage(
            //             image: NetworkImage(widget.postModel.postImages[0]),
            //             fit: BoxFit.cover,
            //             colorFilter: ColorFilter.mode(AppColors.primaryBlack.withOpacity(0.2), BlendMode.srcATop),
            //           ),
            //         ),
            //         child: Center(
            //           child: GestureDetector(
            //             onTap: () {
            //               showOptionsForImagePicking(
            //                 context: context,
            //                 onCameraClicked: () {
            //                   Get.back();
            //                   imageController.pickImage(ImageSource.camera);
            //                 },
            //                 onGalleryClicked: () {
            //                   Get.back();
            //                   imageController.pickImage(ImageSource.gallery);
            //                 },
            //               );
            //             },
            //             child: Icon(Icons.image, size: 30, color: AppColors.primaryWhite),
            //           ),
            //         ),
            //       ),
            SizedBox(height: 20.h),
            Text("Caption", style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
            SizedBox(height: 10.h),
            CustomTextInput(
              controller: _captionController,
              hintText: widget.postModel.caption,
              maxLines: 3,
            ),
            SizedBox(height: 50.h),
            Consumer<LoadingController>(builder: (context, loadingController, child) {
              return loadingController.isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : PrimaryButton(
                      onPressed: () {
                        PostServices()
                            .updatePost(
                          context: context,
                          postId: widget.postModel.postId,
                          caption: _captionController.text.isEmpty ? widget.postModel.caption : _captionController.text,
                          images: _newImageList,
                        )
                            .whenComplete(() {
                          imageController.removeUploadPicture();
                          _captionController.clear();
                        });
                      },
                      title: "Update",
                    );
            })
          ],
        ),
      ),
    );
  }
}
