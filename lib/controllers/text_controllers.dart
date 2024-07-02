import 'package:flutter/cupertino.dart';

class AppTextController extends ChangeNotifier {
  static TextEditingController usernameController = TextEditingController();
  static TextEditingController aboutController = TextEditingController();
  static TextEditingController emailController = TextEditingController();
  static TextEditingController contactController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController confirmPasswordController = TextEditingController();
  static TextEditingController postCaptionController = TextEditingController();
  static TextEditingController commentController = TextEditingController();

  clearTextInput() {
    usernameController.clear();
    emailController.clear();
    aboutController.clear();
    contactController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    postCaptionController.clear();
    commentController.clear();
    notifyListeners();
  }
}
