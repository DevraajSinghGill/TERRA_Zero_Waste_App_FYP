import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/completed_task_page.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/create_task_page.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/pending_task_page.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group_provider.dart';

class GroupActivitiesPage extends StatelessWidget {
  final String groupId;
  final String userId;

  const GroupActivitiesPage({Key? key, required this.groupId, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.setGroupId(groupId);
    taskProvider.setUserId(userId);

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Group Activities',
            style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.create, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTaskPage(groupId: groupId)),
                );
              },
            ),
          ],
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 5.0, color: Colors.white),
              insets: EdgeInsets.symmetric(horizontal: 100.0),
            ),
            tabs: [
              Tab(
                child: Text(
                  'Pending',
                  style: AppTextStyles.nunitoRegular.copyWith(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(Icons.pending_actions, color: Colors.white),
              ),
              Tab(
                child: Text(
                  'Completed',
                  style: AppTextStyles.nunitoRegular.copyWith(color: Colors.white, fontSize: 12),
                ),
                icon: Icon(Icons.check_circle, color: Colors.white),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PendingTasksPage(userId: userId),
            CompletedTasksPage(),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
