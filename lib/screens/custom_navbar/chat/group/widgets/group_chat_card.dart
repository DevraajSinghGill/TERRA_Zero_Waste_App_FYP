import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:terra_zero_waste_app/models/group_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../constants/app_colors.dart';
import '../group_chat_screen.dart';

class GroupChatCard extends StatelessWidget {
  final GroupModel group;
  const GroupChatCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: group.groupImage == ""
              ? CircleAvatar(
                  radius: 30.r,
                  child: Icon(Icons.group),
                )
              : CircleAvatar(
                  radius: 30.r,
                  backgroundImage: NetworkImage(group.groupImage),
                ),
          title: Text(group.groupName, style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroupChatScreen(groupId: group.groupId)),
            );
          },
          subtitle: Text(group.lastMsg),
          trailing: Text(
            timeago.format(group.lastMsgTime),
            style: TextStyle(fontSize: 12.sp, color: AppColors.primaryGrey),
          ),
        ),
        Divider(height: 10),
      ],
    );
  }
}
