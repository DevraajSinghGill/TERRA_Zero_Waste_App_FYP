import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';

class UserController extends ChangeNotifier {
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  List<UserModel> _allUserList = [];
  List<UserModel> get allUserList => _allUserList;

  getUserInformation() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          _userModel = UserModel.fromMap(snapshot);
        } else {
          throw Exception("No User Found!");
        }
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      throw Exception("Error :$e");
    }
  }

  getAllUsers() async {
    try {
      await FirebaseFirestore.instance.collection('users').snapshots().listen((snap) {
        _allUserList = snap.docs.map((doc) => UserModel.fromMap(doc)).toList();
        notifyListeners();
      });
    } catch (e) {}
  }
}
