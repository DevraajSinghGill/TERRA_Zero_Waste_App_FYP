import 'package:get/get.dart';
import 'admin_task.dart';

class AdminTaskController extends GetxController {
  var pendingTasks = <AdminTask>[].obs;
  var approvedTasks = <AdminTask>[].obs;
  var rejectedTasks = <AdminTask>[].obs;

  void approveTask(AdminTask task) {
    task.status.value = "approved";
    pendingTasks.remove(task);
    approvedTasks.add(task);
  }

  void rejectTask(AdminTask task) {
    task.status.value = "rejected";
    pendingTasks.remove(task);
    rejectedTasks.add(task);
  }

  void addTask(AdminTask task) {
    pendingTasks.add(task);
  }
}
