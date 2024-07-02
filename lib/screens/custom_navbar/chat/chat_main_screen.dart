import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/controllers/image_controller.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/widgets/chat_portion.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/widgets/image_sending_portion.dart';
import 'package:terra_zero_waste_app/services/chat_services.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

class ChatMainScreen extends StatefulWidget {
  final String userId;
  const ChatMainScreen({super.key, required this.userId});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final TextEditingController msgController = TextEditingController();
  bool _isLoading = false;
  String docId = "";

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser!.uid.hashCode > widget.userId.hashCode) {
      docId = FirebaseAuth.instance.currentUser!.uid + widget.userId;
    } else {
      docId = widget.userId + FirebaseAuth.instance.currentUser!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageController>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      bottomNavigationBar: imageController.selectedImage != null
          ? SizedBox()
          : ChatInput(
              msgController: msgController,
              onPressed: () {
                _sendMsg(context, imageController, msgController);
              },
            ),
      body: imageController.selectedImage != null
          ? ImageSendingPortion(
              imageController: imageController,
              onSendBtnClick: () {
                _sendMsg(context, imageController, msgController);
              },
              isLoading: _isLoading)
          : ChatPortion(docId: docId),
    );
  }

  void _sendMsg(BuildContext context, ImageController imageController, TextEditingController msgController) async {
    setState(() {
      _isLoading = true;
    });
    if (imageController.selectedImage != null) {
      await ChatServices().sendMsg(
        context: context,
        msg: "Image received",
        docId: docId,
        userId: widget.userId,
        image: imageController.selectedImage,
        postId: "",
      );
      imageController.removeUploadPicture();
    } else {
      await ChatServices().sendMsg(
        context: context,
        msg: msgController.text,
        docId: docId,
        userId: widget.userId,
        image: null,
        postId: "",
      );
      msgController.clear();
    }
    setState(() {
      _isLoading = false;

      FocusScope.of(context).unfocus();
    });
  }
}
