import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:confetti/confetti.dart';
import 'task_group.dart';
import 'task_group_provider.dart';

class PendingTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      return TaskCard(task: task);
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

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  // Implement edit functionality
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  // Implement delete functionality
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
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
                    style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16), // Smaller font size
                  ),
                  subtitle: Text(
                    widget.task.description,
                    style: AppTextStyles.nunitoSemiBod.copyWith(color: Colors.white70, fontSize: 12), // Smaller font size
                  ),
                  trailing: SizedBox(
                    width: 48,
                    height: 48,
                    child: PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.white, size: 32),
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Implement edit functionality
                        } else if (value == 'delete') {
                          // Implement delete functionality
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14), // Customize the font here
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14), // Customize the font here
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0), // Increased button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16), // Increased text size
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
              numberOfParticles: 30, // Increased the number of particles
              colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
