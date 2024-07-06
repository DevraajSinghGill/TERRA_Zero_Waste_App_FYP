import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terra_zero_waste_app/models/group_task_model.dart';

class GroupTaskDetailsScreen extends StatelessWidget {
  final String taskId;
  const GroupTaskDetailsScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('tasks').doc(taskId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          GroupTaskModel task = GroupTaskModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.imageUrl.isNotEmpty)
                      Center(
                        child: Image.asset(task.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    SizedBox(height: 10),
                    Text('Task Name: ${task.taskName}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Description: ${task.description}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text('Points: ${task.points}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text('Group ID: ${task.groupId}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
