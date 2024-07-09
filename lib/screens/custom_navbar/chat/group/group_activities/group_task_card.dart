import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:confetti/confetti.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group.dart';
import 'edit_task_page.dart';
import 'task_group_provider.dart';


class TaskCard extends StatefulWidget {
  final Task task;

  TaskCard({required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _completeTask() {
    _confettiController.play();
    Provider.of<TaskProvider>(context, listen: false).completeTask(widget.task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task Completed')),
    );
  }

  void _editTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskPage(task: widget.task),
      ),
    );
  }

  void _deleteTask() {
    Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task Deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            constraints: BoxConstraints(minHeight: 150),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/teamwork.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    widget.task.title,
                    style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    widget.task.description,
                    style: AppTextStyles.nunitoSemiBod.copyWith(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: SizedBox(
                    width: 48,
                    height: 48,
                    child: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.white, size: 32),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editTask();
                        } else if (value == 'delete') {
                          _deleteTask();
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
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.task.images.map((imagePath) {
                    return Image.network(
                      imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.task.points} points',
                        style: AppTextStyles.nunitoMedium.copyWith(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[900],
                        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: _completeTask,
                      child: Text('Complete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
