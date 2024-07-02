import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class ChatStream {
  Stream<List<DocumentSnapshot>> combineChatStreams() {
    var userChatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('uids', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    var groupChatsStream = FirebaseFirestore.instance
        .collection('groupChats')
        .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return CombineLatestStream.list([userChatsStream, groupChatsStream]).map((list) {
      var allChats = list.expand((i) => i).toList();

      allChats.sort((a, b) {
        DateTime aTime = a.reference.path.contains('chats') ? a['createdAt'].toDate() : a['lastMsgTime'].toDate();
        DateTime bTime = b.reference.path.contains('chats') ? b['createdAt'].toDate() : b['lastMsgTime'].toDate();
        return bTime.compareTo(aTime);
      });

      return allChats;
    });
  }

  Stream<List<DocumentSnapshot>> combineChatStreamForPost() {
    var userChatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('uids', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    var groupChatsStream = FirebaseFirestore.instance
        .collection('groupChats')
        .where('userIds', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return CombineLatestStream.list([userChatsStream, groupChatsStream]).map((list) {
      var allChats = list.expand((i) => i).toList();

      return allChats;
    });
  }
}
