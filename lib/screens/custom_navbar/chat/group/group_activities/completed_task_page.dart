import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'task_group_provider.dart';

class CompletedTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.completedTasks;
        return ListView.builder(
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
                    image: AssetImage('lib/assets/images/teamwork.jpg'),
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
                    Text(
                      task.title,
                      style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16), // Smaller font size
                    ),
                    SizedBox(height: 8.0), // Space between title and description
                    Text(
                      task.description,
                      style: AppTextStyles.nunitoSemiBod.copyWith(color: Colors.white70, fontSize: 12), // Smaller font size
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
