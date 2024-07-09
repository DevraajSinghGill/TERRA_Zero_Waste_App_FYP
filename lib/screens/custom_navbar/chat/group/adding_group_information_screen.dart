import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/controllers/loading_controller.dart';
import 'package:terra_zero_waste_app/services/group_chat_services.dart';
import 'package:terra_zero_waste_app/widgets/buttons.dart';
import 'package:terra_zero_waste_app/widgets/show_options_for_image_picking.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

class AddingGroupInformationScreen extends StatefulWidget {
  final List userIds;
  const AddingGroupInformationScreen({super.key, required this.userIds});

  @override
  State<AddingGroupInformationScreen> createState() => _AddingGroupInformationScreenState();
}

class _AddingGroupInformationScreenState extends State<AddingGroupInformationScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Group Information",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 20), // Custom font style for AppBar
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              imageController.selectedImage == null
                  ? Center(
                      child: CircleAvatar(
                        radius: 45.r,
                        child: Center(
                          child: GestureDetector(
                              onTap: () {
                                showOptionsForImagePicking(
                                  context: context,
                                  onCameraClicked: () {
                                    Get.back();
                                    imageController.pickImage(ImageSource.camera);
                                  },
                                  onGalleryClicked: () {
                                    Get.back();
                                    imageController.pickImage(ImageSource.gallery);
                                  },
                                );
                              },
                              child: Icon(Icons.camera_alt)),
                        ),
                      ),
                    )
                  : Center(
                      child: CircleAvatar(
                        radius: 45.r,
                        backgroundImage: FileImage(File(imageController.selectedImage!.path)),
                      ),
                    ),
              SizedBox(height: 20.h),
              Text("Group Title", style: AppTextStyles.nunitoBold.copyWith(fontSize: 20)),
              SizedBox(height: 10.h),
              CustomTextInput(
                hintText: "Enter your group name",
                controller: _titleController,
              ),
              SizedBox(height: 20.h),
              Text("Group Description", style: AppTextStyles.nunitoBold.copyWith(fontSize: 20)),
              SizedBox(height: 10.h),
              CustomTextInput(
                hintText: "Enter your group description",
                maxLines: 3,
                controller: _descriptionController,
              ),
              SizedBox(height: 50.h),
              Consumer<LoadingController>(builder: (context, loadingController, child) {
                return loadingController.isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor),
                      )
                    : PrimaryButton(
                        onPressed: () {
                          GroupChatServices()
                              .createGroup(
                            context: context,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            image: imageController.selectedImage,
                            userIds: widget.userIds,
                          )
                              .then((e) {
                            imageController.removeUploadPicture();
                            setState(() {
                              _titleController.clear();
                              _descriptionController.clear();
                              widget.userIds.clear();
                            });
                          });
                        },
                        title: "Create Group",
                      );
              })
            ],
          ),
        ),
      ),
    );
  }
}
