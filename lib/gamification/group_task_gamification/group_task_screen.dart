import 'package:flutter/material.dart';
import 'package:terra_zero_waste_app/gamification/group_task_gamification/group_task_list.dart';

class GroupTasksScreen extends StatelessWidget {
  final String groupId;
  const GroupTasksScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group Tasks'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All Tasks'),
              Tab(text: 'Completed Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GroupTaskList(groupId: groupId, showCompleted: false),
            GroupTaskList(groupId: groupId, showCompleted: true),
          ],
        ),
      ),
    );
  }
}
