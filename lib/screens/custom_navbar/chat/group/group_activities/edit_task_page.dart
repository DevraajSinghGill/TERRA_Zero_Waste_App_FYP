import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/constants/app_colors.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';
import 'task_group_provider.dart';
import 'task_group.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _pointsController;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _pointsController = TextEditingController(text: widget.task.points.toString());
    _images = List<String>.from(widget.task.images);
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      Task updatedTask = Task(
        id: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        status: widget.task.status,
        points: int.parse(_pointsController.text),
        images: _images,
      );
      Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
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
                'Changes saved successfully!',
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
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(String imagePath) {
    setState(() {
      _images.remove(imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/create_task.gif?alt=media&token=fef3fa40-cc9c-4c2c-8833-3a1e3f0584a6',
                  height: 150, // Adjusted the height to make it bigger
                ),
                SizedBox(height: 16.0),
                Text(
                  'Edit the task details below.',
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _images.map((imagePath) {
                    return Stack(
                      children: [
                        Image.network(
                          imagePath,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeImage(imagePath),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: Icon(Icons.done, color: Colors.white),
                  label: Text('Save Changes', style: AppTextStyles.nunitoBold.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900], // Set button color to green
                    minimumSize: Size(double.infinity, 50), // Make button full width
                    textStyle: TextStyle(fontSize: 18),
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
