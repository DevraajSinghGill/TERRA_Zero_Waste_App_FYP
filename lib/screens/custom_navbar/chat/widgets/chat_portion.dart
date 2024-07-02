import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../models/message_model.dart';
import 'msg_card.dart';

class ChatPortion extends StatelessWidget {
  final String docId;
  const ChatPortion({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(docId)
          .collection('messages')
          .orderBy('sendingTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("No Msg Found"),
          );
        }
        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            MessageModel messageModel = MessageModel.fromMap(snapshot.data!.docs[index]);

            return MsgCard(messageModel: messageModel);
          },
        );
      },
    );
  }
}
