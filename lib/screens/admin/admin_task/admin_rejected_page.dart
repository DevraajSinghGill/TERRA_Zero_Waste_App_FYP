import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_manage/admin_task_controller.dart';

class AdminRejectedPage extends StatelessWidget {
  const AdminRejectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminTaskController taskController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Rejected Tasks'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: taskController.rejectedTasks.length,
          itemBuilder: (context, index) {
            final task = taskController.rejectedTasks[index];
            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(task.description),
                trailing: Text(
                  "Rejected",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
