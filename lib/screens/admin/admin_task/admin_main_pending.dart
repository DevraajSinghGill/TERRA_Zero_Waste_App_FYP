import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_manage/admin_task_controller.dart';

class AdminPendingPage extends StatelessWidget {
  const AdminPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminTaskController taskController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Tasks'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: taskController.pendingTasks.length,
          itemBuilder: (context, index) {
            final task = taskController.pendingTasks[index];
            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(task.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: Text("Approve", style: TextStyle(color: Colors.green)),
                      onPressed: () {
                        taskController.approveTask(task);
                      },
                    ),
                    TextButton(
                      child: Text("Reject", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        taskController.rejectTask(task);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
