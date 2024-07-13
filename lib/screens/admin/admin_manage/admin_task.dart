import 'package:get/get.dart';

class AdminTask {
  final String id;
  final String description;
  var status = "pending".obs;

  AdminTask({required this.id, required this.description, String? status}) {
    if (status != null) {
      this.status.value = status;
    }
  }
}
