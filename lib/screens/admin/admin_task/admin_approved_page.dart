import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_approved_task_card.dart';
import 'package:terra_zero_waste_app/screens/admin/admin_manage/admin_task_controller.dart';

class AdminApprovedPage extends StatelessWidget {
  const AdminApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminTaskController taskController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Tasks'),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: taskController.approvedTasks.length,
          itemBuilder: (context, index) {
            final task = taskController.approvedTasks[index];
            return ApprovedTaskCard(task: task);
          },
        );
      }),
    );
  }
}
