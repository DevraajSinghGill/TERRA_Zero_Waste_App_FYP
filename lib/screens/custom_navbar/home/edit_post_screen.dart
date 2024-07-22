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

  @override
  void initState() {
    super.initState();
    _captionController.text = widget.postModel.caption;
    getImagesFromDb();
  }

  Future<void> getImagesFromDb() async {
    _images = widget.postModel.postImages!;
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Post", style: AppTextStyles.nunitoBold.copyWith(fontSize: 20.sp, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20), // Added space
              Row(
                children: [
                  Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/image_icon.gif?alt=media&token=95a5e3f3-c5f0-4692-a620-c438cda95634',
                    height: 50.h,
                    width: 50.w,
                  ),
                  SizedBox(width: 10),
                  Text("Select Image", style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp)),
                ],
              ),
              SizedBox(height: 5),
              Text("Choose an image from your gallery or take a new one.",
                  style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp)),
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
                        },
                        child: Icon(Icons.add_circle, color: AppColors.primaryColor, size: 24),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 15),
                      height: 60,
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
              SizedBox(height: 20), // Additional space
              Row(
                children: [
                  Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/caption_icon.gif?alt=media&token=e1993d7e-61a5-415c-b23a-20e3e06f80c2',
                    height: 50.h,
                    width: 50.w,
                  ),
                  SizedBox(width: 10),
                  Text("Add Caption", style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp)),
                ],
              ),
              SizedBox(height: 5),
              Text("Write a caption for your post.",
                  style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp)),
              SizedBox(height: 10),
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
      ),
    );
  }
}
