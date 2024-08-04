import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group_provider.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

class CreateTaskPage extends StatefulWidget {
  final String groupId;

  const CreateTaskPage({super.key, required this.groupId});

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white, 
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/create_task.gif?alt=media&token=fef3fa40-cc9c-4c2c-8833-3a1e3f0584a6',
                  height: 150, 
                ),
                SizedBox(height: 16.0),
                Text(
                  'Create a new task for your group. Fill in the title, description, and points for this task.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.nunitoMedium.copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 16.0),
                CustomTextInput(
                  controller: _titleController,
                  hintText: 'Title',
                ),
                SizedBox(height: 16.0),
                CustomTextInput(
                  controller: _descriptionController,
                  hintText: 'Description',
                  maxLines: 3,
                ),
                SizedBox(height: 16.0),
                CustomTextInput(
                  controller: _pointsController,
                  hintText: 'Points',
                  inputType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final task = Task(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          points: int.parse(_pointsController.text),
                          images: [], // Assuming you still need to pass an empty list for images
                        );
                        Provider.of<TaskProvider>(context, listen: false)
                            .addTask(task);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Task Created')));
                        Navigator.pop(context); // Go back after creating task
                      }
                    },
                    icon: Icon(Icons.done, color: Colors.white),
                    label: Text('Confirm Task', style: AppTextStyles.nunitoBold.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[900], // Set button color to green
                      minimumSize: Size(double.infinity, 50), // Make button full width
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
