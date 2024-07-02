import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/post_model.dart';

class PostController extends ChangeNotifier {
  List<PostModel> _postListModel = [];
  List<PostModel> get postListModel => _postListModel;

  List<PostModel> _myPostModelList = [];
  List<PostModel> get myPostModelList => _myPostModelList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  getAllPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots().listen((snap) {
        _postListModel = snap.docs.map((doc) => PostModel.fromMap(doc)).toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to load posts: $e";
      notifyListeners();
    }
  }

  getAllMyPost() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((snap) {
        _myPostModelList = snap.docs.map((e) => PostModel.fromMap(e)).toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to load posts: $e";
      notifyListeners();
    }
  }
}
