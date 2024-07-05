import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/handler/auth_exception_handler.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/custom_navbar.dart';
import 'package:terra_zero_waste_app/services/image_compress_services.dart';
import 'package:terra_zero_waste_app/services/storage_services.dart';
import '../controllers/loading_controller.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/custom_msg.dart';

class AuthServices extends ChangeNotifier {
  Future<void> signUp({
    required BuildContext context,
    File? image,
    required String username,
    required String about,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (username.isEmpty) {
      showCustomMsg(context, "First name required");
    } else if (email.isEmpty) {
      showCustomMsg(context, "E-mail required");
    } else if (password.isEmpty) {
      showCustomMsg(context, "Password required");
    } else if (password != confirmPassword) {
      showCustomMsg(context, "Password did not match");
    } else {
      try {
        Provider.of<LoadingController>(context, listen: false).setLoading(true);
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

        String? imageUrl;
        if (image != null) {
          final _compressImage = await compressImage(image);
          imageUrl = await StorageServices().uploadImageToDb(_compressImage);
        }

        UserModel userModel = UserModel(
          userId: FirebaseAuth.instance.currentUser!.uid,
          username: username,
          email: email,
          about: about,
          image: imageUrl ?? "",
          followers: [],
          following: [],
          savePosts: [],
          memberSince: DateTime.now(),
        );
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set(userModel.toMap());
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        Get.offAll(() => CustomNavBar());
      } on FirebaseAuthException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);

        final status = AuthExceptionHandler.handleException(e);
        final res = AuthExceptionHandler.generateExceptionMessage(status);
        showCustomMsg(context, res);
      }
    }
  }

  Future<void> login({required BuildContext context, required String email, required String password}) async {
    if (email.isEmpty) {
      showCustomMsg(context, "E-mail required");
    } else if (password.isEmpty) {
      showCustomMsg(context, "Password required");
    } else {
      try {
        Provider.of<LoadingController>(context, listen: false).setLoading(true);
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        Provider.of<LoadingController>(context, listen: false).setLoading(false);

        Get.offAll(() => CustomNavBar());
      } on FirebaseAuthException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);

        final status = AuthExceptionHandler.handleException(e);
        final msg = AuthExceptionHandler.generateExceptionMessage(status);
        showCustomMsg(context, msg);
      }
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      showCustomMsg(context, "E-mail required");
    } else {
      try {
        Provider.of<LoadingController>(context, listen: false).setLoading(true);
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        Provider.of<LoadingController>(context, listen: false).setLoading(false);

        showCustomMsg(context, "A Password Reset Email has been sent to $email please Check and reset your password");
        Get.back();
      } on FirebaseAuthException catch (e) {
        Provider.of<LoadingController>(context, listen: false).setLoading(false);
        showCustomMsg(context, e.message!);
      }
    }
  }

  Future<String> signInWithGoogle() async {
    String response = "";
    try {
      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set(
              {
                'displayName': user.displayName,
                'email': user.email,
                'photoURL': user.photoURL,
                'description': "",
                'followers': [],
                'following': [],
              },
            );
          }
        }
        response = "Login Successful";
        Get.offAll(() => CustomNavBar());
      } else {
        response = "Oops! Login unsuccessful!";
      }
    } catch (error) {
      return error.toString();
    }
    return response;
  }

  static signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => LoginScreen());
  }
}
