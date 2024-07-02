import 'package:firebase_auth/firebase_auth.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyInUse,
  wrongPassword,
  weakPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class AuthExceptionHandler {
  static handleException(FirebaseAuthException e) {
    AuthResultStatus result;
    switch (e.code) {
      case "invalid-email":
        result = AuthResultStatus.invalidEmail;
        break;
      case "wrong-password":
        result = AuthResultStatus.wrongPassword;
        break;
      case "user-not-found":
        result = AuthResultStatus.userNotFound;
        break;
      case "user-disabled":
        result = AuthResultStatus.userDisabled;
        break;
      case "too-many-requests":
        result = AuthResultStatus.tooManyRequests;
        break;
      case "operation-not-allowed":
        result = AuthResultStatus.operationNotAllowed;
        break;
      case "email-already-in-use":
        result = AuthResultStatus.emailAlreadyInUse;
        break;
      case "weak-password":
        result = AuthResultStatus.weakPassword;
        break;
      default:
        result = AuthResultStatus.undefined;
    }
    return result;
  }

  static String generateExceptionMessage(AuthResultStatus status) {
    String errorMessage;
    switch (status) {
      case AuthResultStatus.invalidEmail:
        errorMessage = "Invalid Email.";
        break;
      case AuthResultStatus.wrongPassword:
        errorMessage = "Your password is wrong.";
        break;
      case AuthResultStatus.userNotFound:
        errorMessage = "User with this email doesn't exist.";
        break;
      case AuthResultStatus.userDisabled:
        errorMessage = "User with this email has been disabled.";
        break;
      case AuthResultStatus.tooManyRequests:
        errorMessage = "Too many requests. Try again later.";
        break;
      case AuthResultStatus.operationNotAllowed:
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      case AuthResultStatus.emailAlreadyInUse:
        errorMessage = "The email has already been registered. Please login or reset your password.";
        break;
      case AuthResultStatus.weakPassword:
        errorMessage = "The password provided is too weak.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }
    return errorMessage;
  }
}
