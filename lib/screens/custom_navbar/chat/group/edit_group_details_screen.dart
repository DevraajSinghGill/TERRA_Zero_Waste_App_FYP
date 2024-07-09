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

class EditGroupDetailsPage extends StatefulWidget {
  final String groupId;
  const EditGroupDetailsPage({super.key, required this.groupId});

  @override
  State<EditGroupDetailsPage> createState() => _EditGroupDetailsPageState();
}

class _EditGroupDetailsPageState extends State<EditGroupDetailsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    final groupDetails = await GroupChatServices().getGroupDetails(widget.groupId);
    setState(() {
      _titleController.text = groupDetails['groupName'];
      _descriptionController.text = groupDetails['description'] ?? '';
      _imageUrl = groupDetails['groupImage'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Group Details",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    showOptionsForImagePicking(
                      context: context,
                      onCameraClicked: () {
                        Get.back();
                        imageController.pickImage(ImageSource.camera).then((pickedFile) {
                          setState(() {
                            _selectedImage = pickedFile;
                          });
                        });
                      },
                      onGalleryClicked: () {
                        Get.back();
                        imageController.pickImage(ImageSource.gallery).then((pickedFile) {
                          setState(() {
                            _selectedImage = pickedFile;
                          });
                        });
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 45.r,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path))
                        : (_imageUrl != null ? NetworkImage(_imageUrl!) : null) as ImageProvider?,
                    child: _selectedImage == null && _imageUrl == null
                        ? Icon(Icons.camera_alt, size: 45.r)
                        : null,
                  ),
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
                        onPressed: () async {
                          await GroupChatServices().updateGroup(
                            context: context,
                            groupId: widget.groupId,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            image: _selectedImage,
                          );
                          Navigator.pop(context);
                        },
                        title: "Save Changes",
                      );
              })
            ],
          ),
        ),
      ),
    );
  }
}
