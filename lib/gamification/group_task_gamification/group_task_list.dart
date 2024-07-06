import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terra_zero_waste_app/gamification/group_task_gamification/group_task_details_screen.dart';
import 'package:terra_zero_waste_app/models/group_task_model.dart';

class GroupTaskList extends StatelessWidget {
  final String groupId;
  final bool showCompleted;

  const GroupTaskList({Key? key, required this.groupId, this.showCompleted = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('groupId', isEqualTo: groupId)
          .where('completed', isEqualTo: showCompleted)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            GroupTaskModel task = GroupTaskModel.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>);
            return ListTile(
              title: Text(task.taskName),
              subtitle: Text(task.description),
              trailing: showCompleted
                  ? null
                  : ElevatedButton(
                      onPressed: () {
                        _completeTask(context, task);
                      },
                      child: Text('Complete Task'),
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupTaskDetailsScreen(taskId: task.taskId)),
                );
              },
            );
          },
        );
      },
    );
  }

  void _completeTask(BuildContext context, GroupTaskModel task) async {
    // Update points for each group member
    DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('groups').doc(task.groupId).get();
    List<String> memberIds = List<String>.from(groupDoc['members']);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String memberId in memberIds) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(memberId);
      batch.update(userRef, {'points': FieldValue.increment(task.points)});
    }

    batch.update(FirebaseFirestore.instance.collection('tasks').doc(task.taskId), {'completed': true});

    batch.commit();
  }
}
