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
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "TERRA Chatbot",
    profileImage:
        "https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/organic_splash.gif?alt=media&token=573e4fe7-8012-45b0-a724-8a924cb790cb",
  );

  @override
  void initState() {
    super.initState();
    gemini = Gemini.instance; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "TERRA Chatbot",
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white), 
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(
      children: [
        Container(
          color: Colors.white, 
          child: DashChat(
            inputOptions: InputOptions(
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
          Image.network(
            'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/chatbot_icon.gif?alt=media&token=23207baa-125c-4c92-a423-a694f2708fab',
            height: 150,
            width: 150,
          ),
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
}
