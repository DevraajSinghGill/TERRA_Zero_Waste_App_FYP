import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/group/group_activities/task_group_provider.dart';

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
  List<String> _images = [];
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _pointsController,
                  decoration: InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter points';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text('Add Images'),
                _images.isEmpty
                    ? Icon(Icons.image, size: 100, color: Colors.grey)
                    : Wrap(
                        spacing: 8.0,
                        children: _images
                            .map((image) =>
                                Image.network(image, width: 100, height: 100))
                            .toList(),
                      ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _images.add('https://via.placeholder.com/150');
                    });
                  },
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('Add Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final task = Task(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        points: int.parse(_pointsController.text),
                        images: _images,
                      );
                      Provider.of<TaskProvider>(context, listen: false)
                          .addTask(task);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Task Created')));
                      Navigator.pop(context); // Go back after creating task
                    }
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
