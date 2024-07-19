import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/edit_task_page.dart';
import 'task_group_provider.dart';
import 'task_group.dart';

class PendingTasksPage extends StatelessWidget {
  final String userId; // Add user ID

  PendingTasksPage({required this.userId});

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/tick_icon.gif?alt=media&token=acbe61ca-7d35-49a7-be3d-834ebe00aab1',
                height: 100,
              ),
              SizedBox(height: 16),
              Text(
                'Success',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Task completed successfully!',
                style: AppTextStyles.nunitoMedium.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green[900], // Set text color to white
                  minimumSize: Size(100, 40), // Set button size
                ),
                child: Text('OK', style: AppTextStyles.nunitoBold.copyWith(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _completeTask(BuildContext context, Task task) {
    Provider.of<TaskProvider>(context, listen: false).completeTask(task);
    _showSuccessDialog(context);
  }

  void _editTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskPage(task: task),
      ),
    );
  }

  void _deleteTask(BuildContext context, Task task) {
    Provider.of<TaskProvider>(context, listen: false).deleteTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task Deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set the user ID in the provider
    Provider.of<TaskProvider>(context, listen: false).setUserId(userId);

    return Scaffold(
      body: Container(
        color: Colors.white, // Set background color to white
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final tasks = taskProvider.pendingTasks;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/pending_task.gif?alt=media&token=fdd5bd7e-a8a5-4d90-a80c-197035a28399',
                          height: 150,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Here are your pending tasks. Complete them to earn points and contribute to your group\'s progress!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(25.0), // Increased padding inside the container
                          constraints: BoxConstraints(minHeight: 180), // Increased the minimum height for the container
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/teamwork.jpg?alt=media&token=5a41f53d-ed06-4fc1-b9e8-0c1f990dc593'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  task.title,
                                  style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16),
                                ),
                                subtitle: Text(
                                  task.description,
                                  style: AppTextStyles.nunitoSemiBod.copyWith(color: Colors.white70, fontSize: 12),
                                ),
                                trailing: PopupMenuButton(
                                  icon: Icon(Icons.more_vert, color: Colors.white, size: 32), // Increased icon size
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editTask(context, task);
                                    } else if (value == 'delete') {
                                      _deleteTask(context, task);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.0), // Space between description and points
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green[600], // Changed to green color
                                    borderRadius: BorderRadius.circular(20), // Rounded edges
                                  ),
                                  child: Text(
                                    '${task.points} points',
                                    style: AppTextStyles.nunitoMedium.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0), // Space between points and button
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _completeTask(context, task);
                                  },
                                  icon: Icon(Icons.done, color: Colors.white),
                                  label: Text('Complete Task', style: AppTextStyles.nunitoBold.copyWith(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[900], // Set button color to green
                                    minimumSize: Size(150, 40), // Set button size
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
