import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/widgets/group_chat_portion.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/widgets/image_sending_portion_in_group.dart';
import 'package:terra_zero_waste_app/services/group_chat_services.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

import '../../../../controllers/image_controller.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController msgController = TextEditingController();

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Group Chat"),
      ),
      bottomNavigationBar: imageController.selectedImage != null
          ? SizedBox()
          : ChatInput(
              msgController: msgController,
              onPressed: () {
                _sendChat(context, imageController, msgController);
              },
            ),
      body: imageController.selectedImage != null
          ? ImageSendingPortionInGroup(
              imageController: imageController,
              onSendBtnClick: () {
                _sendChat(context, imageController, msgController);
              },
              isLoading: _isLoading)
          : GroupChatPortion(groupId: widget.groupId),
    );
  }

  void _sendChat(BuildContext context, ImageController imageController, TextEditingController chatController) async {
    setState(() {
      _isLoading = true;
    });

    if (imageController.selectedImage != null) {
      await GroupChatServices().sendMsgInGroup(
        context: context,
        msg: '',
        image: imageController.selectedImage,
        groupId: widget.groupId,
        postId: "",
      );

      imageController.removeUploadPicture();
    } else if (chatController.text.isNotEmpty) {
      await GroupChatServices().sendMsgInGroup(
        context: context,
        msg: chatController.text,
        image: null,
        groupId: widget.groupId,
        postId: "",
      );
      chatController.clear();
    }

    setState(() {
      _isLoading = false;
      FocusScope.of(context).unfocus();
    });
  }
}
