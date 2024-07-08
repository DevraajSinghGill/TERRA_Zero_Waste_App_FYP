import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _HomePageState();
}

class _HomePageState extends State<ChatbotPage> {
  late Gemini gemini;
  String? _gifIconUrl;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    gemini = Gemini.instance; // Direct initialization
    _loadGifIcon();
  }

  Future<void> _loadGifIcon() async {
    try {
      String url = await FirebaseStorage.instance
          .ref('chatbot_icon.gif') // Replace with your file path in Firebase Storage
          .getDownloadURL();
      setState(() {
        _gifIconUrl = url;
      });
    } catch (e) {
      print('Error loading GIF icon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "TERRA Chatbot",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white), // Set the text color to white
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        Container(
          color: Colors.white, // Set background color to white
          child: DashChat(
            inputOptions: InputOptions(
              trailing: [
                IconButton(
                  onPressed: _sendMediaMessage,
                  icon: const Icon(
                    Icons.image,
                  ),
                  iconSize: 40, // Increase the size of the icon
                ),
              ],
              inputDecoration: InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), 
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), 
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            currentUser: currentUser,
            onSend: _sendMessage,
            messages: messages,
          ),
        ),
        if (messages.isEmpty) _buildPlaceholder(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _gifIconUrl != null
              ? Image.network(
                  _gifIconUrl!,
                  height: 150,
                  width: 150,
                )
              : CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            "Chat with a Chatbot!",
            style: AppTextStyles.nunitoBold.copyWith(fontSize: 24),
          ),
          SizedBox(height: 10),
          Text(
            "Start a conversation by sending a message",
            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(
            () {
              messages = [lastMessage!, ...messages];
            },
          );
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
